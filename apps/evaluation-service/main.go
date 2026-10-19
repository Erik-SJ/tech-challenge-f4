package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/go-redis/redis/v8"
	"github.com/joho/godotenv"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.34.0"
)

// Contexto global para o Redis
var ctx = context.Background()

var (
	evaluationRequests = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "evaluation_http_requests_total",
			Help: "Total de HTTP requests recebidas pelo evaluation-service.",
		},
		[]string{"method", "path", "status"},
	)

	evaluationRequestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name: "evaluation_http_request_duration_seconds",
			Help: "Duração das HTTP requests do evaluation-service em segundos.",
		},
		[]string{"method", "path"},
	)
)

func init() {
	prometheus.MustRegister(evaluationRequests)
	prometheus.MustRegister(evaluationRequestDuration)
}

type statusRecorder struct {
	http.ResponseWriter
	statusCode int
}

func (r *statusRecorder) WriteHeader(statusCode int) {
	r.statusCode = statusCode
	r.ResponseWriter.WriteHeader(statusCode)
}

func metricsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		recorder := &statusRecorder{
			ResponseWriter: w,
			statusCode:     http.StatusOK,
		}

		next.ServeHTTP(recorder, r)

		evaluationRequests.WithLabelValues(
			r.Method,
			r.URL.Path,
			http.StatusText(recorder.statusCode),
		).Inc()

		evaluationRequestDuration.WithLabelValues(
			r.Method,
			r.URL.Path,
		).Observe(time.Since(start).Seconds())
	})
}

type App struct {
	RedisClient         *redis.Client
	SqsSvc              *sqs.SQS
	SqsQueueURL         string
	HttpClient          *http.Client
	FlagServiceURL      string
	TargetingServiceURL string
}

func initTracer(ctx context.Context) (func(context.Context) error, error) {
	endpoint := os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")

	if endpoint == "" {
		endpoint = "localhost:4317"
	}

	exporter, err := otlptracegrpc.New(
		ctx,
		otlptracegrpc.WithEndpoint(endpoint),
		otlptracegrpc.WithInsecure(),
	)
	if err != nil {
		return nil, err
	}

	res, err := resource.New(
		ctx,
		resource.WithAttributes(
			semconv.ServiceName("evaluation-service"),
		),
	)
	if err != nil {
		return nil, err
	}

	tracerProvider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(res),
	)

	otel.SetTracerProvider(tracerProvider)

	otel.SetTextMapPropagator(
		propagation.NewCompositeTextMapPropagator(
			propagation.TraceContext{},
			propagation.Baggage{},
		),
	)

	return tracerProvider.Shutdown, nil
}

func main() {
	_ = godotenv.Load()

	ctx := context.Background()

	shutdownTracer, err := initTracer(ctx)
	if err != nil {
		log.Fatalf("Não foi possível inicializar o OpenTelemetry: %v", err)
	}

	defer func() {
		if err := shutdownTracer(context.Background()); err != nil {
			log.Printf("Erro ao finalizar OpenTelemetry: %v", err)
		}
	}()

	port := os.Getenv("PORT")
	if port == "" {
		port = "8004"
	}

	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		log.Fatal("REDIS_URL deve ser definida (ex: redis://localhost:6379)")
	}

	flagSvcURL := os.Getenv("FLAG_SERVICE_URL")
	if flagSvcURL == "" {
		log.Fatal("FLAG_SERVICE_URL deve ser definida")
	}

	targetingSvcURL := os.Getenv("TARGETING_SERVICE_URL")
	if targetingSvcURL == "" {
		log.Fatal("TARGETING_SERVICE_URL deve ser definida")
	}

	sqsQueueURL := os.Getenv("AWS_SQS_URL")
	awsRegion := os.Getenv("AWS_REGION")

	if sqsQueueURL == "" {
		log.Println("Atenção: AWS_SQS_URL não definida. Eventos não serão enviados.")
	}

	if awsRegion == "" && sqsQueueURL != "" {
		log.Fatal("AWS_REGION deve ser definida para usar SQS")
	}

	opt, err := redis.ParseURL(redisURL)
	if err != nil {
		log.Fatalf("Não foi possível parsear a URL do Redis: %v", err)
	}

	rdb := redis.NewClient(opt)

	if _, err := rdb.Ping(ctx).Result(); err != nil {
		log.Fatalf("Não foi possível conectar ao Redis: %v", err)
	}

	log.Println("Conectado ao Redis com sucesso!")

	var sqsSvc *sqs.SQS

	if sqsQueueURL != "" {
		sess, err := session.NewSession(
			&aws.Config{
				Region: aws.String(awsRegion),
			},
		)
		if err != nil {
			log.Fatalf("Não foi possível criar sessão AWS: %v", err)
		}

		sqsSvc = sqs.New(sess)

		log.Println("Cliente SQS inicializado com sucesso.")
	}

	httpClient := &http.Client{
		Timeout:   5 * time.Second,
		Transport: otelhttp.NewTransport(http.DefaultTransport),
	}

	app := &App{
		RedisClient:         rdb,
		SqsSvc:              sqsSvc,
		SqsQueueURL:         sqsQueueURL,
		HttpClient:          httpClient,
		FlagServiceURL:      flagSvcURL,
		TargetingServiceURL: targetingSvcURL,
	}

	mux := http.NewServeMux()

	mux.Handle("/metrics", promhttp.Handler())

	mux.HandleFunc("/health", app.healthHandler)

	mux.Handle(
		"/evaluate",
		metricsMiddleware(
			otelhttp.NewHandler(
				http.HandlerFunc(app.evaluationHandler),
				"evaluation-service /evaluate",
			),
		),
	)

	log.Printf(
		"Serviço de Avaliação (Go) rodando na porta %s",
		port,
	)

	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatal(err)
	}
}

package main

import (
        "context"
        "database/sql"
        "log"
        "net/http"
        "os"

        _ "github.com/jackc/pgx/v4/stdlib"
        "github.com/joho/godotenv"

        "go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
        "go.opentelemetry.io/otel"
        "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
        "go.opentelemetry.io/otel/propagation"
        "go.opentelemetry.io/otel/sdk/resource"
        sdktrace "go.opentelemetry.io/otel/sdk/trace"
        semconv "go.opentelemetry.io/otel/semconv/v1.34.0"
)

// App struct (para injeção de dependência)
type App struct {
        DB        *sql.DB
        MasterKey string
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
                        semconv.ServiceName("auth-service"),
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

        // --- Configuração ---
        port := os.Getenv("PORT")
        if port == "" {
                port = "8001"
        }

        databaseURL := os.Getenv("DATABASE_URL")
        if databaseURL == "" {
                log.Fatal("DATABASE_URL deve ser definida")
        }

        masterKey := os.Getenv("MASTER_KEY")
        if masterKey == "" {
                log.Fatal("MASTER_KEY deve ser definida")
        }

        // --- Conexão com o Banco ---
        db, err := connectDB(databaseURL)
        if err != nil {
                log.Fatalf("Não foi possível conectar ao banco de dados: %v", err)
        }
        defer db.Close()

        app := &App{
                DB:        db,
                MasterKey: masterKey,
        }

        // --- Rotas da API ---
        mux := http.NewServeMux()

        mux.HandleFunc("/health", app.healthHandler)

        mux.Handle(
                "/validate",
                otelhttp.NewHandler(
                        http.HandlerFunc(app.validateKeyHandler),
                        "auth-service /validate",
                ),
        )

        mux.Handle(
                "/admin/keys",
                otelhttp.NewHandler(
                        app.masterKeyAuthMiddleware(
                                http.HandlerFunc(app.createKeyHandler),
                        ),
                        "auth-service /admin/keys",
                ),
        )

        handler := otelhttp.NewHandler(
                mux,
                "auth-service",
        )

        log.Printf(
                "Serviço de Autenticação (Go) rodando na porta %s",
                port,
        )

        if err := http.ListenAndServe(":"+port, handler); err != nil {
                log.Fatal(err)
        }
}

// connectDB inicializa e testa a conexão com o PostgreSQL
func connectDB(databaseURL string) (*sql.DB, error) {
        db, err := sql.Open("pgx", databaseURL)
        if err != nil {
                return nil, err
        }

        if err = db.Ping(); err != nil {
                return nil, err
        }

        log.Println("Conectado ao PostgreSQL com sucesso!")
        return db, nil
}

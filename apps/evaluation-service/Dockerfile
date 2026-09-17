FROM golang:1.25-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./

RUN go get go.opentelemetry.io/otel go.opentelemetry.io/otel/sdk go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc go.opentelemetry.io/otel/propagation go.opentelemetry.io/otel/trace

RUN go mod tidy

COPY . .

RUN go build -o evaluation-service .

FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache ca-certificates wget

COPY --from=builder /src/evaluation-service /app/evaluation-service

RUN chmod +x /app/evaluation-service

EXPOSE 8004

CMD ["./evaluation-service"]

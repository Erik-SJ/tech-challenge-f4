FROM golang:1.24-alpine AS builder

WORKDIR /src

COPY . .

RUN go build -o evaluation-service .


FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache ca-certificates wget

COPY --from=builder /src/evaluation-service /app/evaluation-service

RUN chmod +x /app/evaluation-service

EXPOSE 8004

CMD ["./evaluation-service"]
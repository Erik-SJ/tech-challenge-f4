FROM golang:1.24-alpine AS builder

WORKDIR /src

COPY . .

RUN go build -o auth-service .


FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache ca-certificates wget

# Baixa o bundle oficial da AWS RDS
RUN wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
    -O /etc/ssl/certs/aws-rds-global-bundle.pem

# Atualiza store de certificados
RUN update-ca-certificates    

COPY --from=builder /src/auth-service /app/auth-service

RUN chmod +x /app/auth-service

EXPOSE 8001

CMD ["./auth-service"]
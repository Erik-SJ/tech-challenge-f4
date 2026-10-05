FROM python:3.11-slim-bookworm AS builder

WORKDIR /src

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        build-essential \
        gcc \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Baixa o certificado AWS
RUN mkdir -p /certs && \
    curl -o /certs/aws-rds-global-bundle.pem \
    https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem

COPY requirements.txt .

RUN pip install --upgrade pip

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim-bookworm

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local

COPY --from=builder /certs/aws-rds-global-bundle.pem /certs/aws-rds-global-bundle.pem

COPY app.py .

EXPOSE 8003

CMD ["python", "app.py"]

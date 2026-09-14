variable "aws_region" {
  description = "AWS Region utilizada no provisionamento"
  type        = string
}

variable "environment" {
  description = "Ambiente da infraestrutura"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR principal da VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones utilizadas"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR das Subnets do EKS"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDRs das Subnets do RDS"
  type        = list(string)
}

variable "redis_subnets" {
  description = "CIDR das Subnets do Redis"
  type        = list(string)
}

variable "cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.35"
}

variable "node_instance_types" {
  description = "Tipos de instância dos nodes"
  type        = list(string)
  default = [
    "t3.medium"
  ]
}

variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "aws_session_token" {
  type      = string
  sensitive = true
}



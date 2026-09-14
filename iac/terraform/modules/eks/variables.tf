variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets dos Nodes EKS"
  type        = list(string)
}

variable "node_security_group_id" {
  description = "Security Group dos Nodes EKS"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.35"
}

variable "node_instance_types" {
  description = "Tipos de instância dos Nodes"
  type        = list(string)

  default = [
    "t3.medium"
  ]
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "redis_subnet_ids" {
  description = "IDs das subnets do Redis"
  type        = list(string)
}

variable "redis_security_group_id" {
  description = "ID do Security Group do Redis"
  type        = string
}

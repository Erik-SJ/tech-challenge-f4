variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "rds_subnet_group_name" {
  description = "DB Subnet Group criado no networking"
  type        = string
}

variable "rds_security_group_id" {
  description = "Security Group RDS criado no networking"
  type        = string
}

variable "secret_name" {
  description = "Nome do Secret Manager existente"
  type        = string
}

variable "engine_version" {
  description = "Versão PostgreSQL"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "Classe das instâncias RDS"
  type        = string
  default     = "db.t3.micro"
}

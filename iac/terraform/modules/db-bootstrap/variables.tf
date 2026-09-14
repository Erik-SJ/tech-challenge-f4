variable "subnet_id" {

  description = "Subnet pública onde a EC2 temporária será criada"
  type        = string

}

variable "security_group_ids" {

  description = "Security Groups associados à EC2 temporária"
  type        = list(string)

}

variable "instance_profile_name" {

  description = "Instance Profile da EC2 para acesso via SSM"
  type        = string

}

variable "postgres_credentials" {

  description = "Credenciais do PostgreSQL"
  type = object({

    username = string
    password = string

  })

  sensitive = true

}

variable "postgres_databases" {

  description = "Informações dos bancos PostgreSQL"

  type = map(object({

    endpoint = string
    port     = number
    database = string

  }))

}

variable "postgres_sql_files" {

  description = "Arquivos SQL para inicialização dos bancos"

  type = map(string)

}

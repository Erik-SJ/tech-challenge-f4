data "aws_secretsmanager_secret" "postgres" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "postgres" {
  secret_id = data.aws_secretsmanager_secret.postgres.id
}

locals {

  postgres_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.postgres.secret_string
  )
}

# Instâncias RDS (PostgreSQL)
resource "aws_db_instance" "postgres" {

  for_each = local.databases

  identifier = each.value.identifier

  engine = "postgres"

  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage = 20

  storage_type = "gp3"

  db_name = each.value.database_name

  username = local.postgres_credentials["POSTGRES_USER"]

  password = local.postgres_credentials["POSTGRES_PASSWORD"]

  port = 5432

  db_subnet_group_name = var.rds_subnet_group_name

  vpc_security_group_ids = [

    var.rds_security_group_id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 0

  skip_final_snapshot = true

  deletion_protection = false

  tags = merge(

    local.common_tags,

    {

      Name = each.value.identifier

    }
  )
}

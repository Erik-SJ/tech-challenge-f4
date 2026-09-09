output "postgres_databases" {

  value = {
    for key, db in aws_db_instance.postgres :
    key => {
      endpoint = db.address
      port     = db.port
      database = db.db_name
    }
  }

}

output "postgres_credentials" {

  value = {
    username = local.postgres_credentials["POSTGRES_USER"]
    password = local.postgres_credentials["POSTGRES_PASSWORD"]
  }

  sensitive = true

}

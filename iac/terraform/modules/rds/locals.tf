locals {

  name = "${var.project_name}-${var.environment}"

  databases = {

    auth = {
      identifier    = "auth-db"
      database_name = "dbauth"
    }

    flag = {
      identifier    = "flag-db"
      database_name = "dbflag"
    }

    targeting = {
      identifier    = "targeting-db"
      database_name = "dbtargeting"
    }

  }

  common_tags = {

    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"

  }
}

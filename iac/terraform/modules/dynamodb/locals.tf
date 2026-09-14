locals {

  name = "${var.project_name}-${var.environment}"

  table_name = "ToggleMasterAnalytics"

  common_tags = {

    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"

  }
}

locals {

  name = "${var.project_name}-${var.environment}"

  repositories = [

    "analytics-service",
    "auth-service",
    "evaluation-service",
    "flag-service",
    "targeting-service"

  ]

  common_tags = {

    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"

  }
}

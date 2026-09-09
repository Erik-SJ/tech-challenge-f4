locals {

  name = "${var.project_name}-${var.environment}"

  queue_name = "evaluation-service"

  common_tags = {

    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"

  }
}

locals {

  name = "${var.project_name}-${var.environment}"

  redis_name = "evaluation-redis"

  common_tags = {

    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"

  }
}

locals {

  name = "${var.project_name}-${var.environment}"

  cluster_name = "eks-${local.name}"

  common_tags = {

    Project = var.project_name
    Environment = var.environment
    Terraform = "true"

  }
}
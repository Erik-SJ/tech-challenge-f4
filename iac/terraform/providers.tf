provider "aws" {

  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token

  default_tags {

    tags = {
      Project   = var.project_name
      Terraform = "true"
    }
  }
}

provider "kubernetes" {

  host = module.eks.cluster_endpoint

  cluster_ca_certificate = base64decode(
    module.eks.cluster_certificate_authority_data
  )
  exec {

    api_version = "client.authentication.k8s.io/v1beta1"

    command = "aws"

    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]

  }
}
provider "helm" {
  kubernetes {

    host = module.eks.cluster_endpoint

    cluster_ca_certificate = base64decode(
      module.eks.cluster_certificate_authority_data
    )
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"

      command = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]

    }

  }
}

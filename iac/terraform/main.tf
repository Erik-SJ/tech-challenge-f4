module "networking" {

  source = "./modules/networking"

  project_name = var.project_name

  environment = var.environment

  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnets = var.public_subnets

  private_subnets = var.private_subnets

  redis_subnets = var.redis_subnets

}

# module "dynamodb" {

#   source = "./modules/dynamodb"

#   project_name = var.project_name

#   environment = var.environment

# }

# module "sqs" {

#   source = "./modules/sqs"

#   project_name = var.project_name

#   environment = var.environment

# }

# module "ecr" {

#   source = "./modules/ecr"

#   project_name = var.project_name

#   environment = var.environment

# }

# module "rds" {

#   source = "./modules/rds"

#   project_name = var.project_name

#   environment = var.environment

#   rds_subnet_group_name = module.networking.rds_subnet_group_name

#   rds_security_group_id = module.networking.rds_security_group_id

#   secret_name = "postgres_credentials"

#   depends_on = [
#     module.networking
#   ]

# }

# module "db-bootstrap" {

#   source = "./modules/db-bootstrap"

#   subnet_id = module.networking.eks_public_subnet_ids[0]

#   security_group_ids = [
#     module.networking.eks_nodes_security_group_id
#   ]

#   instance_profile_name = "LabInstanceProfile"

#   postgres_databases = module.rds.postgres_databases

#   postgres_credentials = module.rds.postgres_credentials
#   postgres_sql_files = {

#     auth      = file("${path.module}/modules/rds/sql/auth.sql")
#     flag      = file("${path.module}/modules/rds/sql/flag.sql")
#     targeting = file("${path.module}/modules/rds/sql/targeting.sql")

#   }

#   depends_on = [
#     module.rds
#   ]

# }

# module "redis" {

#   source = "./modules/redis"

#   project_name = var.project_name

#   environment = var.environment

#   redis_subnet_ids = module.networking.redis_subnet_ids

#   redis_security_group_id = module.networking.redis_security_group_id

#   depends_on = [
#     module.networking
#   ]

# }

module "eks" {

  source = "./modules/eks"

  project_name = var.project_name

  environment = var.environment

  vpc_id = module.networking.vpc_id

  subnet_ids = module.networking.eks_public_subnet_ids

  node_security_group_id = module.networking.eks_nodes_security_group_id

  cluster_version = var.cluster_version

  node_instance_types = var.node_instance_types

  depends_on = [
    module.networking
  ]

}

module "ingress_nginx" {

  source = "./modules/ingress-nginx"
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    module.eks
  ]

}

module "argocd" {

  source = "./modules/argocd"
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    module.eks
  ]

}

module "argocd_bootstrap" {

  source = "./modules/argocd-bootstrap"
  providers = {
    kubernetes = kubernetes
  }

  depends_on = [
    module.argocd
  ]

}

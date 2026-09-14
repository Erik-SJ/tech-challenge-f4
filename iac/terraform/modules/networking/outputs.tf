output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.this.id
}

output "redis_security_group_id" {
  description = "ID do Security Group do Redis"
  value       = aws_security_group.sg-redis.id
}

output "redis_subnet_ids" {
  description = "IDs das subnets do Redis"
  value       = aws_subnet.redis[*].id
}

output "rds_subnet_group_name" {
  description = "Nome do DB Subnet Group"
  value       = aws_db_subnet_group.rds.id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.sg-rds.id
}

output "eks_public_subnet_ids" {
  description = "IDs das subnets públicas do EKS"
  value       = aws_subnet.public[*].id
}

output "eks_nodes_security_group_id" {
  description = "ID do Security Group dos nodes EKS"
  value       = aws_security_group.sg-eks-nodes.id
}

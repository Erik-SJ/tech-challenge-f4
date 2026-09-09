# VPC
resource "aws_vpc" "this" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(

    local.common_tags,

    {

      Name = "vpc-${local.name}"

    }
  )
}

# Internet Gateway (VPC)
resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = merge(

    local.common_tags,

    {

      Name = "igw-${local.name}"

    }
  )
}

# Route Table (IGW / VPC)
resource "aws_route_table" "rt" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id

  }

  tags = merge(

    local.common_tags,

    {

      Name = "rt-${local.name}"

    }
  )
}

# Associação da Route table nas Subnets Publicas
resource "aws_route_table_association" "rt-subnet" {

  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.rt.id
}

# Public Subnets
resource "aws_subnet" "public" {

  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(

    local.common_tags,

    {

      Name = "subnet-public-${count.index + 1}-${local.name}"

    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {

  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(

    local.common_tags,

    {

      Name = "subnet-private-${count.index + 1}-${local.name}"

    }
  )
}

# Redis Subnets
resource "aws_subnet" "redis" {

  count             = length(var.redis_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.redis_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(

    local.common_tags,

    {

      Name = "subnet-redis-${count.index + 1}-${local.name}"

    }
  )
}

# DB Subnet Group
resource "aws_db_subnet_group" "rds" {

  name        = "db-subnet-group-${local.name}"
  description = "Grupo de Subnets para o RDS"
  subnet_ids  = aws_subnet.private[*].id

  tags = merge(

    local.common_tags,

    {

      Name = "db-subnet-group-${local.name}"

    }
  )
}

# Security Group (Nodes)
resource "aws_security_group" "sg-eks-nodes" {

  name        = "sg_eks_nodes"
  description = "Security Group dos Nodes EKS"
  vpc_id      = aws_vpc.this.id

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [

      "0.0.0.0/0"
    ]
  }

  tags = merge(

    local.common_tags,

    {

      Name = "sg-eks-nodes-${local.name}"

    }
  )
}

# Security Group (RDS)
resource "aws_security_group" "sg-rds" {

  name        = "sg_db"
  description = "Security Group do RDS"
  vpc_id      = aws_vpc.this.id

  ingress {

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = [

      aws_security_group.sg-eks-nodes.id
    ]
  }

  tags = merge(

    local.common_tags,

    {

      Name = "sg-db-${local.name}"

    }
  )
}

# Security Group (Redis)
resource "aws_security_group" "sg-redis" {

  name        = "sg_redis"
  description = "Security Group do Redis"
  vpc_id      = aws_vpc.this.id

  ingress {

    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"

    security_groups = [

      aws_security_group.sg-eks-nodes.id
    ]

  }

  tags = merge(

    local.common_tags,

    {

      Name = "sg-redis-${local.name}"

    }
  )
}


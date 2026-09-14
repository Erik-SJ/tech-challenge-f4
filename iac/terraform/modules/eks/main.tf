data "aws_iam_role" "lab" {
  name = "LabRole"
}

# Cluster EKS
resource "aws_eks_cluster" "this" {

  name     = local.cluster_name
  role_arn = data.aws_iam_role.lab.arn
  version  = var.cluster_version

  vpc_config {

    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = local.common_tags
}

resource "aws_security_group_rule" "cluster_to_nodes" {

  type = "ingress"

  security_group_id        = var.node_security_group_id
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id

  from_port = 0
  to_port   = 65535
  protocol  = "-1"

}

resource "aws_eks_addon" "vpc_cni" {

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.this
  ]

}

resource "aws_eks_addon" "coredns" {

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.this
  ]

}

resource "aws_eks_addon" "kube_proxy" {

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.this
  ]

}

resource "aws_eks_addon" "monitoring-agent" {

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "eks-node-monitoring-agent"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.this
  ]

}

# Launch Template
resource "aws_launch_template" "eks_nodes" {

  name_prefix = "template-${local.cluster_name}-"

  vpc_security_group_ids = [

    var.node_security_group_id,
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id

  ]

  update_default_version = true

  tags = local.common_tags

}

# Managed Node Group
resource "aws_eks_node_group" "this" {

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "node-${local.cluster_name}"
  node_role_arn   = data.aws_iam_role.lab.arn
  subnet_ids      = var.subnet_ids

  launch_template {

    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version

  }

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND"

  scaling_config {

    desired_size = 2
    min_size     = 1
    max_size     = 2

  }

  tags = local.common_tags

}

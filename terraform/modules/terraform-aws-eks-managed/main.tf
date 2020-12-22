resource "aws_security_group" "cluster" {
  name_prefix = "eks.cluster.${var.name}."
  description = "EKS ENI SG"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = -1
    self        = true
    from_port   = 0
    to_port     = 0
    description = "self"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                                     = "eks.cluster.${var.name}"
    "kubernetes.io/cluster/${var.name}" = "owned"
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = 7
  tags = {
    Name        = var.name
    Environment = terraform.workspace
  }
}

resource "aws_eks_cluster" "main" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version
  tags = {
    Name        = var.name
    Environment = terraform.workspace
  }

  enabled_cluster_log_types = var.enable_cluster_logs ? var.enabled_cluster_log_types : null

  vpc_config {
    subnet_ids         = var.subnets
    security_group_ids = list(aws_security_group.cluster.id)
  }
  depends_on = [ aws_cloudwatch_log_group.main ]
}


provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = [ "--region", data.aws_region.current.name, "eks", "get-token", "--cluster-name", aws_eks_cluster.main.id ]
    env = {
      "AWS_PROFILE" = var.profile
    }
  }
}

resource "aws_eks_node_group" "main" {
  count           = length(var.node_groups)
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = lookup(var.node_groups[count.index], "name", "${var.name}-${count.index}")
  node_role_arn   = lookup(var.node_groups[count.index], "node_role_arn", aws_iam_role.nodes.arn)
  subnet_ids      = lookup(var.node_groups[count.index], "subnets", var.subnets)
  version         = lookup(var.node_groups[count.index], "cluster_version", aws_eks_cluster.main.version)
  ami_type        = lookup(var.node_groups[count.index], "ami_type", null)
  disk_size       = lookup(var.node_groups[count.index], "disk_size", null)
  instance_types  = lookup(var.node_groups[count.index], "instance_types", null)
  labels          = lookup(var.node_groups[count.index], "labels", null)
  release_version = lookup(var.node_groups[count.index], "release_version", null)
  tags = {
    Name        = var.name
    Environment = terraform.workspace
  }

  dynamic "remote_access" {
    for_each = lookup(var.node_groups[count.index], "remote_access", [])
    content {
      ec2_ssh_key                 = lookup(remote_access.value, "ec2_ssh_key", null)
      source_security_group_ids   = lookup(remote_access.value, "source_security_group_ids", null)
    }
  }

  scaling_config {
    desired_size = lookup(var.node_groups[count.index], "desired_size", 1)
    max_size     = lookup(var.node_groups[count.index], "max_size", 1)
    min_size     = lookup(var.node_groups[count.index], "min_size", 1)
  }
}

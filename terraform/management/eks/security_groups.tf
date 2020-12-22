locals {
  provisioner_cidr = "${data.terraform_remote_state.network.outputs["provisioner_ip"]}/32"
}

##########################
# ALB Ingress controller #
##########################
resource "aws_security_group" "alb" {
  name        = "allow http and https for alb"
  description = "allow http and https for alb"
  vpc_id      = local.vpc.id

  dynamic "ingress" {
    for_each = var.allowed_cidrs
    content {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
      cidr_blocks = ingress.value
      description = ingress.key
    }
  }

  dynamic "ingress" {
    for_each = var.allowed_cidrs
    content {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
      cidr_blocks = ingress.value
      description = ingress.key
    }
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = [ "0.0.0.0/0" ]
  }
}

##########################
# ALB Ingress controller #
##########################
resource "aws_security_group" "alb_customers" {
  name        = "allow http and https for alb for customers"
  description = "allow http and https for alb for customers"
  vpc_id      = local.vpc.id

  dynamic "ingress" {
    for_each = var.allowed_cidrs_customers
    content {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
      cidr_blocks = ingress.value
      description = ingress.key
    }
  }

  dynamic "ingress" {
    for_each = var.allowed_cidrs_customers
    content {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
      cidr_blocks = ingress.value
      description = ingress.key
    }
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group_rule" "workers_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = module.eks.worker_security_group_id
  description              = "allow load balancer sercurity group to access workers"
}

#######
# EFS #
#######
resource "aws_security_group" "efs" {
  name        = "allow efs to be mounted on worker nodes"
  description = "allow efs to be mounted on worker nodes"
  vpc_id      = local.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    security_groups = [ module.eks.worker_security_group_id ]
    description = "eks worker security group"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ local.provisioner_cidr ]

  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = [ "0.0.0.0/0" ]
  }
}

##################################
# management provisioner to EKS #
#################################

resource "aws_security_group_rule" "provisioner_cluster" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [ local.provisioner_cidr ]
  security_group_id = module.eks.cluster_security_group_id
  description       = "allow kubernetes api from provisioner host"
}

resource "aws_security_group_rule" "provisioner_workers" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ local.provisioner_cidr ]
  security_group_id = module.eks.worker_security_group_id
  description       = "allow ssh from provisioner host"
}

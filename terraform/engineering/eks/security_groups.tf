##########################
# ALB Ingress controller #
##########################
resource "aws_security_group" "alb" {
  name_prefix = "alb.${terraform.workspace}.${var.environment}."
  description = "allow http and https for alb"
  vpc_id      = local.vpc.vpc_id

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

  lifecycle {
      ignore_changes = [
        name, name_prefix
      ]
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

###############################
# Our side provisioner to EKS #
###############################

resource "aws_security_group_rule" "management_private_cluster" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = concat(data.terraform_remote_state.management_network.outputs["private_subnet_cidrs"], list(data.terraform_remote_state.network.outputs["provisioner_private_cidr"]))
  security_group_id = module.eks.cluster_security_group_id
  description       = "allow kubernetes api from management private subnets"
}

resource "aws_security_group_rule" "management_private_workers" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = concat(data.terraform_remote_state.management_network.outputs["private_subnet_cidrs"], list(data.terraform_remote_state.network.outputs["provisioner_private_cidr"]))
  security_group_id = module.eks.worker_security_group_id
  description       = "allow ssh from management private subnets"
}

#######
# EFS #
#######
resource "aws_security_group" "efs" {
  name_prefix = "efs.${terraform.workspace}.${var.environment}."
  description = "allow efs to be mounted on worker nodes"
  vpc_id      = local.vpc.vpc_id

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
    cidr_blocks = [ "${data.terraform_remote_state.management_network.outputs["provisioner_ip"]}/32" ]

  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = [ "0.0.0.0/0" ]
  }

  lifecycle {
      ignore_changes = [
        name, name_prefix
      ]
    }
}

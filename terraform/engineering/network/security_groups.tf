###########################
# Client side provisioner #
###########################
resource "aws_security_group" "provisioner" {
  name_prefix = "provisioner.${var.name}.${local.environment}"
  description = "provisioner.${var.name}.${local.environment}"
  vpc_id      = module.vpc.id

  tags = merge({
    Name        = "provisioner.${var.name}.${local.environment}"
    Environment = local.environment
  }, var.tags)
}

resource "aws_security_group_rule" "provisioner_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.provisioner.id
}

resource "aws_security_group_rule" "provisioner_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
  security_group_id = aws_security_group.provisioner.id
}

resource "aws_security_group_rule" "provisioner_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "${data.terraform_remote_state.management_network.outputs["provisioner_ip"]}/32", "${data.terraform_remote_state.management_network.outputs["bastion_private_ip"]}/32" ]
  security_group_id = aws_security_group.provisioner.id
}

resource "aws_security_group_rule" "allow_in_database_default" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = list(module.vpc.cidr)
  security_group_id = data.terraform_remote_state.database_network.outputs.vpc["default_sg"]
}

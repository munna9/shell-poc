locals {
  vpc = data.terraform_remote_state.network.outputs.vpc
}

resource "aws_security_group" "database" {
  name_prefix = "database.${var.name}.${terraform.workspace}."
  description = "RDS Security Group for ${var.name}"
  vpc_id      = local.vpc.id
  tags = merge({
    "Name" = "database.${var.name}.${terraform.workspace}"
  }, var.tags)
}

resource "aws_security_group_rule" "database_egress_allow_all" {
  description       = "allow all egress"
  protocol          = "-1"
  security_group_id = aws_security_group.database.id
  cidr_blocks       = [ "0.0.0.0/0" ]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "database_ingress_allow_all_vpc" {
  description       = "allow all vpc"
  protocol          = -1
  security_group_id = aws_security_group.database.id
  cidr_blocks       = [ local.vpc.cidr ]
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "database_ingress_allow_provisioner" {
  description       = "allow provisioner"
  protocol          = -1
  security_group_id = aws_security_group.database.id
  cidr_blocks       = [ "${data.terraform_remote_state.management_network.outputs["provisioner_ip"]}/32" ]
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}

module "db" {
  source     = "../../modules/terraform-aws-rds"
  name       = "${var.name}-${terraform.workspace}"

  snapshot_identifier        = lookup(var.rds_settings, "snapshot_identifier", null)
  backup_retention_period    = lookup(var.rds_settings, "backup_retention_period", 7)
  skip_final_snapshot        = lookup(var.rds_settings, "skip_final_snapshot", false)
  deletion_protection        = lookup(var.rds_settings, "deletion_protection", true)
  apply_immediately          = lookup(var.rds_settings, "apply_immediately", true)
  final_snapshot_identifier  = lookup(var.rds_settings, "final_snapshot_identifier", "${var.name}-${terraform.workspace}-final-snapshot")
  auto_minor_version_upgrade = true

  multi_az = true
  engine   = var.rds_engine
  storage  = var.rds_storage

  database_name     = var.database_name
  database_username = var.database_username
  database_password = var.database_password

  instance_class     = lookup(var.rds_instance, "instance_class", "db.m5.large")
  subnets            = local.vpc.private_subnets
  security_group_ids = [ aws_security_group.database.id ]

  tags = merge({
    Environment = terraform.workspace
  }, var.tags)
}

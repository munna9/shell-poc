module "vpc" {
  source              = "../../modules/terraform-aws-vpc"
  cidr                = var.vpc_cidr
  name                = "database.${var.name}.${terraform.workspace}"
  nat_per_az          = false
  separate_db_subnets = false

  subnet_outer_offsets   = var.subnet_outer_offsets
  subnet_inner_offsets   = var.subnet_inner_offsets
  tags = var.tags
  transit_gateway_attach = true
  transit_gateway_id = data.terraform_remote_state.management_network.outputs.transit_gateway_id

  allow_cidrs_default  = {
    "management vpc" = data.terraform_remote_state.management_network.outputs.vpc_cidr
  }
}

# route to management vpc
resource "aws_route" "to_management" {
  count                  = length(module.vpc.route_tables)
  route_table_id         = element(module.vpc.route_tables, count.index)
  destination_cidr_block = data.terraform_remote_state.management_network.outputs["vpc_cidr"]
  transit_gateway_id     = data.terraform_remote_state.management_network.outputs["transit_gateway_id"]
  depends_on             = [ module.vpc ]
}

# route from management vpc
resource "aws_route" "from_management" {
  count                  = length(data.terraform_remote_state.management_network.outputs["route_tables"])
  route_table_id         = element(data.terraform_remote_state.management_network.outputs["route_tables"], count.index)
  destination_cidr_block = var.vpc_cidr
  transit_gateway_id     = data.terraform_remote_state.management_network.outputs["transit_gateway_id"]
}

resource "aws_security_group_rule" "rds_default_in_management_default" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  cidr_blocks              = list(module.vpc.cidr)
  security_group_id        = data.terraform_remote_state.management_network.outputs.vpc["default_sg"]
  description              = "database vpc"
}

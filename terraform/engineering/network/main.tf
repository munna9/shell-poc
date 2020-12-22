locals {
  environment = var.environment == null ? terraform.workspace : var.environment
}

module "vpc" {
  source              = "../../modules/terraform-aws-vpc"
  cidr                = var.vpc_cidr
  name                = "${var.name}.${local.environment}"
  nat_per_az          = false
  separate_db_subnets = false

  subnet_outer_offsets   = [ 4, 2, 6 ]
  subnet_inner_offsets   = [ 2, 2 ]

  transit_gateway_attach        = true
  transit_gateway_id            = data.terraform_remote_state.management_network.outputs.transit_gateway_id

  tags = merge({
    "kubernetes.io/cluster/${var.name}-${local.environment}" = "shared"
  }, var.tags)

  public_subnet_tags = merge({
    "kubernetes.io/cluster/${var.name}-${local.environment}" = "shared"
    "kubernetes.io/role/elb"                                 = "1"
  }, var.tags)

  private_subnet_tags = merge({
    "kubernetes.io/cluster/${var.name}-${local.environment}" = "shared"
    "kubernetes.io/role/internal-elb"                        = "1"
  }, var.tags)

  allow_cidrs_default  = {}
}

resource "null_resource" "tag_main_route_table" {
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${element(module.vpc.public_route_tables, 0)} --tags Key=Name,Value=\"public.${var.name}.${local.environment}\" --profile ${var.profile} --region ${var.region} || true"
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
  count                  = var.existing_transit_gateway ? 0 : length(data.terraform_remote_state.management_network.outputs["route_tables"])
  route_table_id         = element(data.terraform_remote_state.management_network.outputs["route_tables"], count.index)
  destination_cidr_block = var.vpc_cidr
  transit_gateway_id     = data.terraform_remote_state.management_network.outputs["transit_gateway_id"]
}

# route to database vpc
resource "aws_route" "to_database" {
  count                  = length(module.vpc.route_tables)
  route_table_id         = element(module.vpc.route_tables, count.index)
  destination_cidr_block = data.terraform_remote_state.database_network.outputs.vpc["cidr"]
  transit_gateway_id     = data.terraform_remote_state.management_network.outputs["transit_gateway_id"]
  depends_on             = [ module.vpc ]
}

# route from database vpc
resource "aws_route" "from_database" {
  count                  = length(data.terraform_remote_state.database_network.outputs.vpc["route_tables"])
  route_table_id         = element(data.terraform_remote_state.database_network.outputs.vpc["route_tables"], count.index)
  destination_cidr_block = var.vpc_cidr
  transit_gateway_id     = data.terraform_remote_state.management_network.outputs["transit_gateway_id"]
}

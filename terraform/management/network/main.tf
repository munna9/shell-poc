resource "aws_ec2_transit_gateway" "main" {
  count       = var.shared_transit_gateway_id == null ? 1 : 0
  description = var.name

  tags = merge({
    Name        = "${var.name}.${terraform.workspace}"
    Environment = terraform.workspace
  }, var.tags)

  lifecycle {
    prevent_destroy = false
  }
}

module "vpc" {
  source                 = "../../modules/terraform-aws-vpc"
  cidr                   = var.vpc_cidr
  name                   = "${var.name}.${terraform.workspace}"
  nat_per_az             = false
  separate_db_subnets    = false
  subnet_outer_offsets   = [ 4, 2, 6 ]
  subnet_inner_offsets   = [ 2, 2 ]
  transit_gateway_attach = true
  transit_gateway_id     = aws_ec2_transit_gateway.main[0].id
  allow_cidrs_default    = {}
  tags = merge({
    "kubernetes.io/cluster/${var.name}-${terraform.workspace}" = "shared"
  }, var.tags)

  public_subnet_tags = merge({
    "kubernetes.io/cluster/${var.name}-${terraform.workspace}" = "shared"
    "kubernetes.io/role/elb"                                   = "1"
  }, var.tags)

  private_subnet_tags = merge({
    "kubernetes.io/cluster/${var.name}-${terraform.workspace}" = "shared"
    "kubernetes.io/role/internal-elb"                          = "1"
  }, var.tags)
}

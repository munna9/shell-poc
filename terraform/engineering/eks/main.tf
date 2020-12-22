locals {
  vpc = data.terraform_remote_state.network.outputs
  environment = var.environment == null ? terraform.workspace : var.environment
  worker_groups_launch_templates = {
    for k,v in var.worker_groups_launch_templates:
      k => merge(v,{"subnets" = local.vpc.private_subnets} ,  {"key_name" = local.vpc.ssh_key_name})
  }

  tags = merge({
    "Name" = "cpu.eks.${var.name}.${local.environment}"
    "management_avinstall" = "disable"
    "Agents_Exception"    = "ssm"
  },
  var.tags)
}

module "eks" {
  source             = "../../modules/terraform-aws-eks"
  cluster_name       = "${local.environment}-${var.name}"
  subnets            = var.eks_public ? local.vpc.public_subnets : local.vpc.private_subnets
  vpc_id             = local.vpc.vpc_id
  config_output_path = "./config_output/"
  manage_cluster_iam_resources    = false
  cluster_iam_role_name           = aws_iam_role.eks_cluster.name
  manage_worker_iam_resources     = false
  cluster_endpoint_private_access = var.eks_public ? false : true
  cluster_endpoint_public_access  = var.eks_public ? true : false
  cluster_version                 = var.cluster_version
  tags  = local.tags
  workers_group_defaults = {
    iam_instance_profile_name = aws_iam_instance_profile.eks_workers.name
  }

  worker_groups_launch_template = local.worker_groups_launch_templates
  map_roles = var.map_roles
  module_depends_on = [ aws_security_group_rule.management_private_cluster ]
}

data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  version                = "1.11.1"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.main.token
  load_config_file       = false

}

module "acm" {
  source      = "../../modules/terraform-aws-acm"
  domain_name = var.domain_name
  dns_zone    = var.dns_zone
}

module "acm" {
  source      = "../../modules/terraform-aws-acm"
  domain_name = var.domain_name
  dns_zone    = var.dns_zone
  tags = merge({
    Name         = "${var.name}.${terraform.workspace}"
    Envinronment = terraform.workspace
  }, var.tags)
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

### OIDC config
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = module.eks.cluster_oidc_issuer_url
}

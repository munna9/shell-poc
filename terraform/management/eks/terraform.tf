data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket      = var.management_state_bucket
    key         = "management/network.tfstate"
    region      = var.region
    profile     = var.profile
    role_arn    = var.role_arn
    external_id = var.external_id
  }
}

terraform {
  backend "s3" {
    key         = "management/eks.tfstate"
    encrypt     = true
    region      = "us-east-1"
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
  assume_role {
    role_arn    = var.role_arn
    external_id = var.external_id
  }
}

/*
provider "kubernetes" {
  version                = "1.10.0"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = [ "--region", var.region, "eks", "get-token", "--cluster-name", module.eks.cluster_id ]
  }
}
*/

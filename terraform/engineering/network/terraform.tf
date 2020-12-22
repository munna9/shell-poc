data "terraform_remote_state" "management_network" {
  backend   = "s3"
  workspace = var.management_workspace
  config = {
    bucket      = var.management_state_bucket
    key         = "management/network.tfstate"
    region      = var.region
    profile     = var.profile
    role_arn    = var.role_arn
    external_id = var.external_id
  }
}

data "terraform_remote_state" "database_network" {
  backend   = "s3"
  workspace = var.database_workspace
  config = {
    bucket      = var.database_state_bucket
    key         = "database/network.tfstate"
    region      = var.region
    profile     = var.profile
    role_arn    = var.role_arn
    external_id = var.external_id
  }
}

terraform {
  backend "s3" {
    key         = "engineering/network.tfstate"
    encrypt     = true
    region      = "us-east-1"
    acl         = "bucket-owner-full-control"
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

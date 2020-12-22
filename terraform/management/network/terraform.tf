terraform {
  backend "s3" {
    key         = "management/network.tfstate"
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

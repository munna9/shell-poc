terraform {
  backend "s3" {
    bucket  = "ne-terraform-staging"
    key     = "openvpn/terraform.tfstate"
    region  = "us-east-1"
    acl     = "bucket-owner-full-control"
    encrypt = true
  }
}

provider "aws" {
  profile     = "prodtf"
  assume_role {
    role_arn    = "arn:aws:iam::651668690081:role/prod-readandwrite"
    external_id = null
  }
  region  = var.aws_region
}

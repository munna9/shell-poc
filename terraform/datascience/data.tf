data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon
}

data "terraform_remote_state" "transit" {
  backend = "s3"

  config = {
    bucket  = "ne-terraform"
    key     = "transit/terraform.tfstate"
    region  = "us-west-2"
    profile = "prod"
  }
}

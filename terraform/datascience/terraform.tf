terraform {
  backend "s3" {
    bucket  = "ne-terraform"
    key     = "datascience/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region  = var.region
}

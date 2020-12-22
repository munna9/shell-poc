terraform {
    backend "s3" {
      key         = "ses/terraform.tfstate"
      encrypt     = true
      region      = "us-east-1"
    }
}

provider "aws" {
  region  = var.region
}

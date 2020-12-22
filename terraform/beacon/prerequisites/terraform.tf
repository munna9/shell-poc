terraform {
  backend "s3" {
    bucket  = "ne-terraform"
    key     = "beacon/prerequisties.tfstate"
    region  = "us-east-1"
    profile = "prod"
    encrypt = true
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

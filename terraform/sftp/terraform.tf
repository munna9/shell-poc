terraform {
  backend "s3" {
    key    = "sftp/terraform.tfstate"
    region = "us-east-1"
    acl    = "bucket-owner-full-control"
  }
}

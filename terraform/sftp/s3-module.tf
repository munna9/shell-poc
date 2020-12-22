module "s3" {
  source            = "./modules/s3"
  region            = "us-east-1"
  bucket-name       = var.bucket-name
  acl               = "private"
  versioning-enable = "true"
}

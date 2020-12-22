module "ses_domain" {
  source             = "../modules/terraform-aws-ses"
  domain_name        = var.domain_name
  from_addresses     = var.from_addresses
  enable_verification = var.enable_verification
}

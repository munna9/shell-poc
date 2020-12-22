profile     = "prod1"
region      = "us-east-1"
role_arn    = "arn:aws:iam::651668690081:role/prod-readandwrite"
external_id = null

vpc_cidr    = "10.22.0.0/16"
domain_name = "*.hub.stage.ep.shell.com"
dns_zone    = "stage.ep.shell.com"

terraform_state_bucket = "ne-terraform-staging"
management_workspace   = "stage"
database_workspace     = "stage"

name                    = "hub"
environment             = "stage"

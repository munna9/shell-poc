profile     = "prod1"
region      = "us-east-1"
role_arn    = "arn:aws:iam::651668690081:role/prod-readandwrite"
external_id = null

vpc_cidr    = "10.20.0.0/16"
domain_name = "*.stage.ep.shell.com"
dns_zone    = "stage.ep.shell.com"

terraform_state_bucket = "ne-terraform-staging"
management_workspace   = "stage"
database_workspace     = "stage"

name                    = "eng"
environment             = "stage"


allowed_cidrs = {
  "jaya_home"            = [ "98.248.136.128/32" ]
  "shell_mobile_connect" = [ "165.225.34.0/23" ]
  "sean_home"            = [ "76.21.5.55/32" ]
  "garrett_home"         = [ "99.174.169.44/32" ]
  "fabio_home"           = [ "73.70.140.144/32" ]
  "kevin_home"           = [ "99.8.65.213/32" ]
  "tamas_home"           = [ "73.93.177.25/32" ]
  "lonnie_home"          = [ "47.219.160.9/32"     ]
  "SENA_RSTOP"           = [ "104.129.195.7/32", "104.129.205.1/32", "165.225.34.187/32"   ]
  "irm_scan"             = [ "208.118.237.224/32", "74.217.87.122/32", "74.217.87.123/32", "74.217.87.78/32", "64.41.200.0/24" ]
}

tags = {
  "Organization"    = "Energy Platform"
  "business_unit"   = "BU:SNEUS"
  "created_by"      = ""
  "owner"           = ""
  "department"      = ""
  "scrum_team"      = "Engineering"
  "application_id"  = "337729"
  "cost_center"     = "290047"
  "version"         = "v.1.0.0"
  "data_owner"      = "Shell Energy Retail Limited (SERL)"
  "customer"        = "Shell"
  "project"         = "management"
}

profile     = "prod1"
region      = "us-east-1"
role_arn    = "arn:aws:iam::651668690081:role/prod-readandwrite"
external_id = null

vpc_cidr               = "10.253.0.0/16"
terraform_state_bucket = "ne-terraform-staging"
management_workspace   = "stage"

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

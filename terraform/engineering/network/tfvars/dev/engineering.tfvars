profile     = "prod1"
region      = "us-east-1"
role_arn    = "arn:aws:iam::317380420770:role/jenkins_agent.stage"
external_id = null

vpc_cidr    = "10.30.0.0/16"
existing_transit_gateway = true

management_state_bucket = "ne-terraform-staging"
database_state_bucket   = "ne-terraform-dev"
management_workspace    = "stage"
database_workspace      = "dev"

name                    = "eng"
environment             = "dev"

tags = {
  "Organization"    = "Energy Platform"
  "business_unit"   = "BU:SNEUS"
  "created_by"      = "nClouds"
  "owner"           = "EP Engineering"
  "department"      = "New Energy"
  "scrum_team"      = "Engineering"
  "application_id"  = "337729"
  "cost_center"     = "290047"
  "version"         = "v.1.0.0"
  "data_owner"      = "Shell Energy Retail Limited (SERL)"
  "customer"        = "Shell"
  "project"         = "management"
}

profile     = "prod1"
region      = "us-east-1"
role_arn    = "arn:aws:iam::651668690081:role/prod-readandwrite"
external_id = null

terraform_state_bucket = "ne-terraform-staging"
management_workspace   = "stage"

rds_settings = {
  snapshot_identifier       = null
  skip_final_snapshot       = false
  final_snapshot_identifier = null
  deletion_protection       = true
  apply_immediately         = true
  backup_retention_period   = 7
}

rds_storage = {
  allocated = 10
  type      = "gp2"
  iops      = null
  encrypted = true
}

rds_instance = {
  instance_class = "db.t3.medium"
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

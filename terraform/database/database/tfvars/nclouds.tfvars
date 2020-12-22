profile                 = "nclouds"
region                  = "us-west-2"
role_arn                = null
external_id             = null
terraform_state_bucket  = "test-shell-nclouds"

rds_storage = {
  allocated = 5
  type      = "gp2"
  encrypted = true
}

rds_instance = {
  instance_class = "db.t3.micro"
}

rds_settings = {
  snapshot_identifier     = null
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true
}

database_username = "newenergy"
database_password = "NewEnergy1nClouds" # this is for testing, donot add password in tfvars file

name = "engineering"

tags = {
  "Team"            = "DevOps"
  "Client"          = "Shell"
  "Owner"           = ""
}

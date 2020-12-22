profile                 = "prod1"
region                  = "us-east-1"
role_arn                = "arn:aws:iam::258010404141:role/ep_servicerole"
external_id             = "1234"
terraform_state_bucket  = "ne-terraform"
name                    = "engineering"
management_workspace    = "production"
database_username       = "newenergy"

rds_storage = {
  allocated = 100
  type      = "io1"
  iops      = 4000
  encrypted = true
}

rds_instance = {
  instance_class = "db.m5.large"
}

rds_settings = {
  snapshot_identifier       = "neprod2"
  final_snapshot_identifier = "neprod-final-snaphot"
  skip_final_snapshot       = false
  deletion_protection       = true
  apply_immediately         = true
}

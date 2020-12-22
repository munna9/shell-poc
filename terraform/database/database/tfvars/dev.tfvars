profile     = "shell-dev"
role_arn    = "arn:aws:iam::317380420770:role/ep_servicerole"
external_id = "1234"

terraform_state_bucket = "ne-terraform-dev"
management_workspace   = "dev"

rds_settings = {
  snapshot_identifier       = "nepg-20200314"
  skip_final_snapshot       = false
  final_snapshot_identifier = null
  deletion_protection       = true
  apply_immediately         = true
  backup_retention_period   = 7
}

rds_storage = {
  allocated = 100
  type      = "gp2"
  iops      = null
  encrypted = true
}

rds_instance = {
  instance_class = "db.t3.medium"
}

# database password can be null when launched from snapshot
database_password = null

variable "name" {
  default = "eng"
}

variable "region" {
  default = "us-east-1"
}

variable "profile" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "external_id" {
  type = string
}

variable "terraform_state_bucket" {
  type = string
}

variable "management_workspace" {
  default = null
}

variable "database_workspace" {
  default = null
}

variable "database_name" {
  type    = string
  default = null
}

variable "database_username" {
  type    = string
  default = "newenergy"
}

variable "database_password" {
  type    = string
}

variable "rds_settings" {
  default = {
    snapshot_identifier       = null
    skip_final_snapshot       = false
    final_snapshot_identifier = null
    deletion_protection       = true
    apply_immediately         = true
    backup_retention_period   = 7
  }
}

variable "rds_storage" {
  default = {
    allocated = 100
    type      = "io1"
    iops      = 4000
    encrypted = true
  }
}

variable "rds_engine" {
  default = {
    name                 = "postgres"
    major_engine_version = "10"
    version              = "10.6"
    family               = "postgres10"
  }
}

variable "rds_instance" {
  default = {
    instance_class = "db.m5.large"
  }
}

variable "tsdb_ami_id" {
  default = {
      us-east-1      = "ami-0032e31c131b98862"
      us-west-2      = "ami-0beb1a82cbf80f965"
    }
}



variable "tsdb_volume_size" {
  default = 100
}

variable "tags" {
  type    = map
  default = {}
}

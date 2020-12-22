variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
  default = null
}
variable "subnets" {
  type = list(string)
}

variable "parameters" {
  type    = list(map(string))
  default = []
}

variable "options" {
  type    = list(map(string))
  default = []
}

variable "engine" {
  type = map(string)
  default = {}
}

variable "instance_class" {
  type = string
}

variable "major_engine_version" {
  type = string
  default = null
}

variable "storage" {
  type    = map(string)
  default = {
    allocated = 10
    type      = "gp2"
    encrypted = false
  }
}

variable "kms_key_id" {
  type        = string
  default     = ""
}

variable "database_name" {
  type    = string
  default = null
}

variable "database_username" {
  type    = string
  default = "admin"
}

variable "database_password" {
  type    = string
}

variable "port" {
  type    = string
  default = 5432
}

variable "iam_database_authentication_enabled" {
  type    = bool
  default = false
}

variable "snapshot_identifier" {
  type    = string
  default = null
}

variable "availability_zone" {
  type    = string
  default = null
}

variable "security_group_ids" {
  type = list(string)
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "monitoring_interval" {
  type = number
  default = 0
}

variable "allow_major_version_upgrade" {
  type = bool
  default = false
}

variable "auto_minor_version_upgrade" {
  type = bool
  default = false
}

variable "apply_immediately" {
  type = bool
  default = false
}

variable "skip_final_snapshot" {
  type = bool
  default = true
}

variable "copy_tags_to_snapshot" {
  type = bool
  default = false
}

variable "final_snapshot_identifier" {
  type    = string
  default = null
}

variable "max_allocated_storage" {
  type    = number
  default = 0
}

variable "enhanced_monitoring" {
  type = bool
  default = false
}

variable "monitoring_role_arn" {
  type = string
  default = ""
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "performance_insights_retention_period" {
  type    = number
  default = 7
}

variable "backup_retention_period" {
  type    = number
  default = 1
}

variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = []
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "timeouts" {
  type = map(string)
  default = {}
}

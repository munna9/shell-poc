variable "name" {
  type    = string
}

variable "cluster_version" {
  type    = string
  default = null
}

variable "node_groups" {
  type = list
}

variable "enable_cluster_logs" {
  type    = bool
  default = false
}

variable "enabled_cluster_log_types" {
  type    = list(string)
  default = null
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "profile" {
  type = string
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "name" {
  default = "eng"
}

variable "environment" {
  default = null
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

variable "no_of_azs" {
  default = 2
}

variable "management_state_bucket" {
  type = string
}

variable "database_state_bucket" {
  type = string
}

variable "management_workspace" {
  default = null
}

variable "database_workspace" {
  default = null
}

variable "existing_transit_gateway" {
  default = false
}

variable "allowed_cidrs" {
  default = {
    "jaya_home"            = [ "98.248.136.128/32" ]
    "shell_mobile_connect" = [ "165.225.34.0/23" ]
    "sean_home"            = [ "76.21.5.55/32" ]
    "garrett_home"         = [ "99.174.169.44/32" ]
    "fabio_home"           = [ "73.70.140.144/32" ]
    "kevin_home"           = [ "99.8.65.213/32" ]
    "tamas_home"           = [ "73.93.177.25/32" ]
    "lonnie_home"          = [ "47.219.160.9/32"	]
    "SENA_RSTOP"           = [ "104.129.195.7/32", "104.129.205.1/32", "165.225.34.187/32"	]
    "irm_scan"             = [ "208.118.237.224/32", "74.217.87.122/32", "74.217.87.123/32", "74.217.87.78/32", "64.41.200.0/24" ]
  }
}

variable "tags" {
  type    = map
  default = {}
}

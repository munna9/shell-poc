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

variable "vpc_cidr" {
  default = "10.254.0.0/16"
}

variable "subnet_outer_offsets"  {
  default = [ 2, 2, 2 ]
}

variable "subnet_inner_offsets" {
  default = [ 2, 2 ]
}

variable "tags" {
  type    = map
  default = {}
}

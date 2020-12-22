variable "profile" {
  type    = string
}

variable "role_arn" {
  type    = string
}

variable "external_id" {
  type    = string
}

variable "region" {
  default = "us-east-1"
}

variable "name" {
  default = "mgmt"
}

variable "vpc_cidr" {
  default = "10.255.0.0/16"
}

variable "shared_transit_gateway_id" {
  default = null
}

variable "provisioner_terraform_version" {
  default = "0.12.24"
}

variable "provisioner_helm_version" {
  default = "3.1.2"
}

variable "workspace_shortcode" {
  default = {
    production  = "prod"
    development = "dev"
    staging     = "stage"
  }
}

variable "allowed_cidrs" {
  type    = list
  default = [
    {
      cidr_blocks = [ "76.218.124.133/32" ]
      description = "Shell-red-cable"
    },
    {
      cidr_blocks = [ "134.163.253.248/32" ]
      description = "shell-main"
    },
    {
      cidr_blocks = [ "76.21.5.55/32" ]
      description = "Sean Home"
    },
    {
      cidr_blocks = [ "73.70.140.144/32" ]
      description = "Fabio"
    },
    {
      cidr_blocks = [ "98.248.136.128/32" ]
      description = "jaya Home"
    },
    {
      cidr_blocks = [ "99.174.169.44/32" ]
      description = "Garrett Home"
    },
    {
      cidr_blocks = [ "52.166.34.55/32", "52.224.237.139/32" ]
      description = "no description"
    },
    {
      cidr_blocks = [ "165.225.34.0/23" ]
      description = "Shell Mobile Connect"
    },
    {
      cidr_blocks = [ "47.219.160.9/32" ]
      description = "Lonnie Home"
    },
    {
      cidr_blocks = [ "73.93.177.25/32" ]
      description = "Tamas Home"
    }
  ]
}

variable "tags" {
  type    = map
  default = {}
}

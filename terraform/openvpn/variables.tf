variable "name" {
  default     = "openvpn"
  description = "OpenVPN instance name"
}

variable "profile" {
  type = string
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "cidr_block" {
  default = "172.16.0.0/16"
}

variable "subnets_cidr" {
  type    = list(string)
  default = ["172.16.2.0/24", "172.16.3.0/24"]
}

variable "instance_type" {
  default = "m4.large"
}
variable "instance_count" {
  default = "2"
}

variable "ebs_region" {
  description = "Region for the EBS volume where we'll store credentials and certificates"
  default     = "us-east-1"
}

variable "availability_zone" {
  type    = list(string)
  default = ["us-east-1b", "us-east-1c"]
}

variable "ebs_size" {
  description = "EBS volume size in GB. 4 should be fine in most cases"
  default     = 4
}

variable "ami" {
  default = "ami-0a5ba7d9384c17232"
}

variable "admin_user" {
  description = "OpenVPN admin username. Admin is reserved"
  default     = "vpnadmin"
}

variable "admin_password" {
  description = "OpenVPN admin password"
}

variable "route53_zone" {
  description = "Zone where the vpn will be hosted"
}

variable "public_dns_name" {
  description = "The public dns name for the openvpn server"
}

variable "tags" {
  type    = map
  default = {}
}
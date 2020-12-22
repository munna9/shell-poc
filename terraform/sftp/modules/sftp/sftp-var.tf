#SFTP Variables
variable "aws_region" {
  default = "us-east-1"
}
variable "aws-transfer-server-name" {
  default = ""
}

variable "IAM-role-name-for-sftp" {
  default = ""
}

variable "s3-access-policy-name" {
  default = ""
}

variable "s3-policy-file-location" {
  default = ""
}

variable "sftp-user-name" {
  default = ""
}

variable "sftp-s3-bucket-name" {
  default = ""
}

variable "ssh-public-key-file-location" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

# variable "securitygroup_cidr" {
#  default = "10.20.4.0/22"
# }

variable "subnet_cidr" {
  default = "10.20.4.0/22"
}

variable "subnet_ids" {
  default = []
}

variable "security_group_id" {
  default = ""
}
variable "sftp_provider_type" {
  default = "SERVICE_MANAGED"
}

variable "endpoint_type" {
  default = "VPC_ENDPOINT"
}

variable "sftp_name" {
  default = ""
}

variable "terraform_state_bucket" {
  type = string
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


variable "domain_name" {
  description = "The domain name to configure SES."
  type        = string
}

variable "from_addresses" {
  description = "List of email addresses."
  type        = list(string)
}

variable "enable_verification" {
  description = "Control whether or not to verify SES DNS records."
  type        = bool
  default     = false
}

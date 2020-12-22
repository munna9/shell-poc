variable "domain_name" {
  description = "The domain name to configure SES."
  type        = string
}

variable "enable_verification" {
  description = "Control whether or not to verify SES DNS records."
  type        = bool
  default     = false
}

variable "from_addresses" {
  description = "List of email addresses."
  type        = list(string)
}

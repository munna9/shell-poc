variable "bucket" {
  # description = "Enter Bucket Name"
  # default     = ""
}
variable "profile" {
  default     = ""
}variable "role_arn" {
  default     = ""
}
variable "region" {
  default     = ""
  description = "AWS Region, defaults to us-east-1"
}
variable "cost_center" {
  type = string
  default     = ""
}
variable "business_unit" {
  type = string
  default     = ""
}
variable "organization" {
  type = string
  default     = ""
}

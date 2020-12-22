variable "aws_region" {
  default     = ""
  description = "AWS Region, defaults to us-east-1"
}
variable "profile" {
  default     = ""
}variable "role_arn" {
  default     = ""
}
variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default = ""
}
variable "buckets" {
  type = list(object({
    bucket_name = string
    lifecycle_name = string # lifecycle is reserved 
  }))
  default = [
  ]
}
variable "owner" {
  default     = ""
}
variable "organization" {
  default     = ""
}
variable "scrum_team" {
  default     = ""
}
variable "data_owner" {
  default     = ""
}
variable "management_avinstall" {
  default     = ""
}
variable "project" {
  default     = ""
}
variable "application_id" {
  default     = ""
}
variable "business_unit" {
  default     = ""
}
variable "customer" {
  default     = ""
}
variable "standard_ia" {
  default     = ""
}
variable "glacier" {
  description = "Transition to Glacier after"
  default     = ""
}
variable "expiration" {
  description = "Expires after"
  default     = ""
}
variable "id" {
  description = "lifecycle id"
  default     = ""
}
variable "enabled" {
  description = "enable the lifecycle"
  default     = ""
}
variable "prefix" {
  description = "Expires after"
  default     = ""
}
variable "environment" {
  default     = ""
}
variable "acl" {
  description = "Set canned ACL on bucket. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write"
}
// variable "cost_center" {
//   default     = ""
// }










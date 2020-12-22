variable "domain_name" {}

variable "dns_zone" {}

variable "subject_alternative_names" {
  type = list(string)
  default = []
}

variable "tags" {
  type = map
  default = {}
}

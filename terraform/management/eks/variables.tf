variable "region" {
  default = "us-east-1"
}

variable "profile" {
  type    = string
}

variable "role_arn" {
  type    = string
}

variable "external_id" {
  type    = string
}

variable "key_pair_name" {
  type    = string
  default = ""
}

variable "management_state_bucket" {
  type    = string
}

variable "name" {
  default = "mgmt"
}

variable "eks_public" {
  default = false
}

variable "domain_name" {
  type = string
  default = "*.prod.ep.shell.com"
  description = "Domain Name to create SSL for EKS external services"
}

variable "dns_zone" {
  type = string
  default = "prod.ep.shell.com"
  description = "DNS Zone to be create domain names for EKS Services external access, should exist in the same AWS account Route53"
}

variable "workspace_shortcode" {
  default = {
    production  = "prod"
    development = "dev"
    staging     = "stage"
  }
}
// At the moment: sg-0ca7d77275eaa40d5
variable "allowed_cidrs" {
  default = {
    "sean_home"               = [ "76.21.5.55/32" ]
    "tamas_home"              = [ "73.93.177.25/32" ]
    "lonnie_home"             = [ "47.219.160.9/32"	]
    "jaya_home"               = [ "73.93.178.235/32" ]
    "kevin_home"              = [ "99.8.65.213/32" ]
    "shell_mobile_connect"    = [ "165.225.34.0/23" ]
    "garrett_home"            = [ "24.5.248.94/32" ]
    "Alex_home"               = [ "76.103.242.3/32" ]
    "mgmt.provisioner.stage"  = [ "34.234.122.145/32" ]
    "cw.stage"                = [ "52.20.74.171/32" ]
    "EU_Shell"                = [ "185.46.212.0/23" ]
    "Aladdine_home"           = [ "24.4.167.101/32" ]
    "runner.pod"              = [ "52.207.96.193/32" ]
    "nClouds VPN"             = [ "52.36.127.34/32" ]
    "eng.stage"               = [ "34.196.209.179/32" ]
    "Christian.home"          = [ "24.4.114.0/23" ]
    "eng.chargeworks.prod.nat"= [ "3.221.213.23/32" ]
    "do-dev"                  = [ "34.235.43.184/32" ]
    "eng.dev.nat"             = ["52.72.219.215/32"]
    "EU Zscaler"              = ["165.225.81.0/24"]
    "US Zscaler"              = ["104.129.202.96/32","104.129.202.0/24"]
    "vara_home"               = ["104.2.54.162/32"]
    "Dinesh.home"             = ["104.129.200.126/32"]
    "Disha_home"              = ["134.163.57.49/32"]
    "raja.home"               = ["73.223.140.30/32"]
  }
}

variable "allowed_cidrs_customers" {
  type    = map
  default = {}
}

variable "jenkins_deployment" {
  default = {
    namespace = "default"
    serviceaccount_master = "jenkins"
    serviceaccount_agent = "jenkins-agent"
  }
}

variable "tags" {
  type    = map
  default = {}
}

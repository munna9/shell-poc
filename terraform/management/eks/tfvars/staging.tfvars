profile     = "prodtf"
region      = "us-east-1"
role_arn    = "arn:aws:iam::651668690081:role/prod-readandwrite"
external_id = null

management_state_bucket = "ne-terraform-staging"

domain_name = "*.stage.ep.shell.com"
dns_zone    = "stage.ep.shell.com"

tags = {
  "Organization"    = "Energy Platform"
  "business_unit"   = "BU:SNEUS"
  "created_by"      = "_"
  "owner"           = "_"
  "department"      = "_"
  "scrum_team"      = "Engineering"
  "application_id"  = "337729"
  "cost_center"     = "290047"
  "version"         = "v.1.0.0"
  "data_owner"      = "Shell Energy Retail Limited - SERL"
  "customer"        = "Shell"
  "project"         = "management"
}

allowed_cidrs_customers = {
  "cw.Mathew.VPN"           = [ "95.248.129.251/32" ]
  "cw.home"                 = [ "81.104.134.132/32", "81.157.91.60/32" ]
  "Chargeworks_office"      = [ "82.163.236.69/32" ]
  "Marta CW"                = [ "86.184.71.206/32" ]
  "Luc CW"                  = ["85.145.234.113/32"]
  "Chris CW"                = ["90.254.60.160/32"]
  "Ilsa-maria CW"           = ["212.182.149.189/32"]
  "Omar CW"                 = ["95.146.149.175/32"]
  "Chad Home"               = [ "2.123.214.69/32" ]
  "chad.m.home"             = [ "86.9.103.51/32" ]
}

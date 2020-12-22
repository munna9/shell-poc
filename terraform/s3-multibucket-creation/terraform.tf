#This profile is for dev env
terraform {
  backend "s3" {
    profile  = "dev"
    role_arn = "arn:aws:iam::317380420770:role/dev-readandwrite"
    bucket   = "ne-backend-dev"
    key      = "dev/terraform.tfstate"
    region   = "us-east-1"
    acl      = "bucket-owner-full-control"
    encrypt  = true
  }
}

#This profile is for stage env
// terraform {
//   backend "s3" {
//     profile = "prodtf"
//     role_arn     = "arn:aws:iam::651668690081:role/ep_servicerole"
//     bucket  = "ne-terraform-staging"
//     key     = "stage/new-energy-dev-lj-datalake/terraform.tfstate"
//     region  = "us-east-1"
//     acl     = "bucket-owner-full-control"
//     encrypt = true
//   }
// }

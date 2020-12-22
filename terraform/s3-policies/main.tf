provider "aws" {
  region = var.region
  profile     = var.profile
  assume_role {
    role_arn = var.role_arn 
    
  }
}

resource "aws_s3_bucket_policy" "ssl" {
  bucket              = var.bucket
policy = <<POLICY
{
   "Id":"sslPolicy",
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"AllowSSLRequestsOnly",
         "Action":"s3:*",
         "Effect":"Deny",
         "Resource":[
            "arn:aws:s3:::${aws_s3_bucket.s3.bucket}",
            "arn:aws:s3:::${aws_s3_bucket.s3.bucket}/*"
         ],
         "Condition":{
            "Bool":{
               "aws:SecureTransport":"false"
            }
         },
         "Principal":"*"
      },
      {
         "Sid":"Prevent bucket delete",
         "Effect":"Deny",
         "Principal":"*",
         "Action":"s3:DeleteBucket",
         "Resource":[
            "arn:aws:s3:::${aws_s3_bucket.s3.bucket}",
            "arn:aws:s3:::${aws_s3_bucket.s3.bucket}/*"
         ]
      }
   ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = var.bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "s3" {
  bucket               = var.bucket
  acl                  = "private"

  tags={
  
    cost_center   = var.cost_center
    business_unit = var.business_unit
    organization  = var.organization
  } 
}
provider "aws" {
  region = var.aws_region
  profile     = var.profile
  assume_role {
    role_arn     = var.role_arn
  }
}

resource "aws_s3_bucket_policy" "ssl" {
  bucket              = aws_s3_bucket.s3.id
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
  bucket = aws_s3_bucket.s3.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "s3" {
  bucket               = var.bucket
  acl                  = var.acl

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm           = var.sse_algorithm
      }
    }
  }
  tags={
 //   cost_center             = var.cost_center
    business_unit           = var.business_unit
    organization            = var.organization
    owner                   = var.owner
    scrum_team              = var.scrum_team
    management_avinstall	  = var.management_avinstall
    project	                = var.project
    application_id	        = var.application_id
    customer                = var.customer
    data_owner              = var.data_owner
  } 
  
  lifecycle_rule {
    id              = "ne-lifecycle-s3"
    enabled         = true
    prefix          = "whole bucket"

    transition {
      days                 = var.standard_ia
      storage_class        = "STANDARD_IA"
    }
    noncurrent_version_transition {
      days                 = var.standard_ia
      storage_class        = "STANDARD_IA"
    }
    transition {
      days                 = var.glacier
      storage_class        = "GLACIER"
    }
    noncurrent_version_transition {
      days                 = var.glacier
      storage_class        = "GLACIER"
    }
    expiration {
      days                 = var.expiration
    }
    noncurrent_version_expiration {
      days                 = var.expiration
    }
  }
  versioning {
    enabled     = true
  }
}


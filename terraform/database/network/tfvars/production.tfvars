profile                 = "prod1"
region                  = "us-east-1"
role_arn                = "arn:aws:iam::258010404141:role/ep_servicerole"
external_id             = "1234"
terraform_state_bucket  = "ne-terraform"

name                    = "engineering"
management_workspace    = "production"
subnet_outer_offsets    = [ 2, 2, 2 ]
subnet_inner_offsets    = [ 2, 2 ]

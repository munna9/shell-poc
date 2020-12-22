# Terraform (IaC) 

Terraform can help you build, change, or version infrastructure of the Energy platform safely and efficiently. 

Configuration files describe to Terraform the cloud components needed to run a single application or your entire data centre. Terraform generates an execution plan, describing what it will do to reach the desired state, and then executes it to build the described cloud infrastructure. As the configuration changes, Terraform can determine what changed and create incremental execution plans. 

The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc. 


Terraform module to provision an S3 bucket to store terraform.tfstate file and a DynamoDB table to lock the state file to prevent concurrent modifications and state corruption. 

### The module supports the following: 

Forced server-side encryption at rest for the S3 bucket 

S3 bucket versioning to allow for Terraform state recovery in the case of accidental deletions and human errors 

State locking and consistency checking via DynamoDB table to prevent concurrent operations 

DynamoDB server-side encryption 


### Terraform State-File Managment

Every time you run Terraform, it records information about what infrastructure it created in a Terraform state file. This file is in JSON format & have mapping from terraform resources.

So after running terraform apply, we can see one more file in our directory i.e terraform.tfstate. When we open that file, we see a long JSON format containing data.

1- What if every team members needs access to the same Terraform state files. That means you need to store those files in a shared location.
2- In case two peoples are running Terraform at the same time, which can lead to conflicts & data loss.

We’re using Terraform with AWS, so Amazon S3 (Simple Storage Service) as a remote backend. As we know about S3, it’s manged service, 9.999999999% durability and 99.99% availability, also supports encryption, versioning, locking via DynamoDB etc.

Versioning: By enabling versioning on the S3 bucket so that every update to a file in the bucket actually creates a new version of that file.
Server_side_encryption_configuration: Secrets always encrypted on disk when stored in S3.

Back-end Configuration:
To configure Terraform to store the state in your S3 bucket, we need to add a backend configuration to your Terraform code.

With this backend enabled, Terraform will automatically pull the latest state from this S3 bucket before running a command, and automatically push the latest state to the S3 bucket after running a command.
After running Terraform init command, your Terraform state will be stored in the S3 bucket.

[Terraform Backend S3](https://www.terraform.io/docs/backends/types/s3.html) 

NOTE: The operators of the module (IAM Users) must have permissions to create S3 buckets and DynamoDB tables when performing terraform plan and terraform apply 

NOTE: This module cannot be used to apply changes to the mfa_delete feature of the bucket. Changes regarding mfa_delete can only be made manually using the root credentials with MFA of the AWS Account where the bucket resides.  

```$terraform init```

```$terraform apply```. This will create the state bucket and locking table.


Now you can see multiple version of your state file. Terraform is automatically pushing and pulling state data to and from S3.

**Then add a backend that uses the new bucket and table**:
```
 backend "s3" {
    region         = "us-east-1"
    bucket         = "< the name of the S3 bucket >"
    key            = "terraform.tfstate"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "< the name of the DynamoDB table >"
    encrypt        = true
   }
 }

 module "another_module" {
   source = "....."
 }
```

Key: The Terraform state is written to the key, The path to the state file inside the bucket.

```$terraform init```. Terraform will detect that you're trying to move your state into S3 and ask, "Do you want to copy existing state to the new backend?" Enter "yes". Now state is stored in the bucket and the DynamoDB table will be used to lock the state to prevent concurrent modifications.
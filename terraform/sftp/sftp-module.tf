module "sftp" {
  source = "./modules/sftp"

  #AWS-SFTP
  aws-transfer-server-name     = "sftp-ne"
  IAM-role-name-for-sftp       = "sftp"
  endpoint_type                = "VPC_ENDPOINT"
  sftp_provider_type           = "SERVICE_MANAGED"
  sftp-user-name               = var.sftp-user-name
  sftp_name                    = var.sftp_name
  sftp-s3-bucket-name          = var.bucket-name
  ssh-public-key-file-location = file("./sftpkey.pub")
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
}

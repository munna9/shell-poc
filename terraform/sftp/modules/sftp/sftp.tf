provider "aws" {
  region = var.aws_region
}
resource "aws_iam_role" "iam-role-sftp" {
  name = var.IAM-role-name-for-sftp
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "sftp" {

  statement {
    sid = "AllowListingBucket"
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.sftp-s3-bucket-name}",
    ]
  }

  statement {
    sid = "AllowReadandWriteandDelete"
    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]

    resources = [
      "arn:aws:s3:::${var.sftp-s3-bucket-name}/*",
    ]
  }
}

resource "aws_iam_role_policy" "iam-role-sftp-policy" {
  name = "sftp-ne-bucket-access"
  role = aws_iam_role.iam-role-sftp.id
  policy = data.aws_iam_policy_document.sftp.json
}

resource "aws_eip" "ep" {
  tags = {
    Name  = var.sftp_name
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["73.93.178.235/32"]
  }
  ingress {
    description = "stfp "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["73.93.178.235/32"]
  }
  ingress {
    description = "stfp "
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["73.93.178.235/32"]
  }


  tags = {
    Name = "allow_tls"
  }
}


# resource "aws_transfer_user" "sftp-user" {
#   server_id      = "${aws_transfer_server.sftp.id}"
#   user_name      = "${var.sftp-user-name}"
#   home_directory = "${var.sftp-s3-bucket-name}"
#   role           = "${aws_iam_role.iam-role-sftp.arn}"
#   tags = {
#     NAME = "${var.sftp-user-name}"
#   }
# }

# resource "aws_transfer_ssh_key" "sftp-ssh" {
#   server_id = "${aws_transfer_server.sftp.id}"
#   user_name = "${aws_transfer_user.sftp-user.user_name}"
#   body      = "${var.ssh-public-key-file-location}"
# }


# resource "aws_transfer_server" "sftp" {
#   identity_provider_type = "${var.sftp_provider_type}"
#   logging_role          = "${aws_iam_role.iam-role-sftp.arn}"
#   endpoint_type = "PUBLIC"
#   tags = {
#     Name  = "${var.sftp_name}"
#   }
# }

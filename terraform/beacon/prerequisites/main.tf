resource "random_string" "main" {
  length  = 16
  special = false
  number  = true
}

resource "aws_iam_role" "main" {
  name = "BeaconClientAdmin"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": [
        "arn:aws:iam::449650826706:role/BeaconClientAdmin"
      ]
    },
    "Action": "sts:AssumeRole",
    "Condition": {
      "StringEquals": {
        "sts:ExternalId": "${random_string.main.result}"
      }
    }
  }]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.main.name
}

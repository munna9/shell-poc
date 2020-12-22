output "external_id" {
  value = random_string.main.result
}

output "cross_account_role_name" {
  value = aws_iam_role.main.name
}

output "rds" {
  value = module.db
}

output "database_security_group" {
  value = aws_security_group.database.id
}

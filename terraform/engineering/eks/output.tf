output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ssl_certificate_arn" {
  value = module.acm.arn
}

output "alb_security_group" {
  value = aws_security_group.alb.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.main.dns_name
}

output "desired_jenkins_hostname" {
  value = "jenkins.${var.dns_zone}"
}

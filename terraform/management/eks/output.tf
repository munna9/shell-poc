output "vpc_id" {
  value = local.vpc.id
}

output "vpc_cidr" {
  value = local.vpc.cidr
}

output "public_subnets" {
  value = local.vpc.public_subnets
}

output "private_subnets" {
  value = local.vpc.private_subnets
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "alb_customers_sg_id" {
  value = aws_security_group.alb_customers.id
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

resource "local_file" "install_values" {
  content = templatefile("${path.module}/files/values.yaml", {
      ssl_certificate_arn       = module.acm.arn
      security_group_ids        = aws_security_group.alb.id
      desired_jenkins_hostname  = "jenkins.${var.dns_zone}"
      eks-role-arn-master       = aws_iam_role.jenkins_master.arn
      eks-role-arn-agent        = aws_iam_role.jenkins_agent.arn
      jenkins_deployment        = var.jenkins_deployment

    }
  )
  filename = "${path.module}/config_output/install_values.yaml"
}

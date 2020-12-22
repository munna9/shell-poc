output "transit_gateway_id" {
  value = var.shared_transit_gateway_id == null ? aws_ec2_transit_gateway.main[0].id : var.shared_transit_gateway_id
}

output "route_tables" {
  value = module.vpc.route_tables
}

output "association_default_route_table_id" {
  value = aws_ec2_transit_gateway.main[0].association_default_route_table_id
}

output "propagation_default_route_table_id" {
  value = aws_ec2_transit_gateway.main[0].propagation_default_route_table_id
}

output "bastion_ip" {
  value = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_eip.bastion.private_ip
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion.id
}

output "ssh_key_name" {
  value = aws_key_pair.main.key_name
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "private_subnet_cidrs" {
  value = module.vpc.private_subnet_cidrs
}

output "provisioner_ip" {
  value = aws_instance.provisioner.private_ip
}

output "provisioner_security_group_id" {
  value = aws_security_group.provisioner.id
}

output "vpc" {
  value = module.vpc
}

output "default_security_group_id" {
  value = module.vpc.default_sg
}

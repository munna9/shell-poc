output "transit_vpc_id" {
  value = data.terraform_remote_state.transit.outputs.transit_gateway_id
}

output "vpc_id" {
  value = module.vpc.id
}

output "vpc_cidr" {
  value = module.vpc.cidr
}

output "default_sg" {
  value = module.vpc.default_sg
}

output "default_sg_name" {
  value = module.vpc.default_sg_name
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}
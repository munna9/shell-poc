variable "name" {
  default = "eng"
}

variable "environment" {
  default = null
}

variable "region" {
  default = "us-east-1"
}

variable "profile" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "external_id" {
  type = string
}

variable "eks_public" {
  default = false
}

variable "domain_name" {
  type = string
  default = "*.prod.ep.shell.com"
  description = "Domain Name to create SSL for EKS external services"
}

variable "dns_zone" {
  type = string
  default = "prod.ep.shell.com"
  description = "DNS Zone to be create domain names for EKS Services external access, should exist in the same AWS account Route53"
}

variable "terraform_state_bucket" {
  type = string
}

variable "management_state_bucket" {
  type = string
}

variable "management_workspace" {
  default = null
}

variable "network_workspace" {
  default = null
}

variable "allowed_cidrs" {
  default = null
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.14"
}

variable "tags" {
  type    = map
  default = {}
}
// set this in the corresponding tfvars file - Only replace the role required for the specific account
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  default = []
}

variable "worker_groups_launch_templates" {
  type    = list(map(any))
  default = [{
        name                  = "cpu"
        kubelet_extra_args    = "--node-labels=name=cpu"
        instance_type         = "m4.4xlarge"
        asg_desired_capacity  = 1
        public_ip             = false
        bootstrap_extra_args  = "--enable-docker-bridge true"
        autoscaling_enabled   = true
        protect_from_scale_in = false
        additional_userdata   = <<EOF
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
EOF

      }]

}

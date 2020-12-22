locals {
  vpc = data.terraform_remote_state.network.outputs.vpc
}

module "eks" {
  source             = "../../modules/terraform-aws-eks"
  cluster_name       = "${var.name}-${terraform.workspace}"
  subnets            = local.vpc.private_subnets
  vpc_id             = local.vpc.id
  tags                  = var.tags
  config_output_path = "./config_output/"
  manage_cluster_iam_resources    = false
  cluster_iam_role_name           = aws_iam_role.eks_cluster.name
  manage_worker_iam_resources     = false
  cluster_endpoint_private_access = var.eks_public ? false : true
  cluster_endpoint_public_access  = var.eks_public ? true : false

  workers_group_defaults = {
    iam_instance_profile_name = aws_iam_instance_profile.eks_workers.name
  }

  worker_groups_launch_template = [{
    name                  = "cpu"
    kubelet_extra_args    = "--node-labels=name=cpu"
    instance_type         = "t3.xlarge"
    asg_desired_capacity  = 1
    public_ip             = false
    bootstrap_extra_args  = "--enable-docker-bridge true"
    autoscaling_enabled   = true
    protect_from_scale_in = false
    tags                  = var.tags
    additional_userdata   = <<EOF
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
EOF

    subnets               = local.vpc.private_subnets
    key_name              = var.key_pair_name == "" ? data.terraform_remote_state.network.outputs["ssh_key_name"] : var.key_pair_name
    tags = [{
      key                 = "Name"
      value               = "cpu.eks.${var.name}.${terraform.workspace}"
      propagate_at_launch = true
    }]
  }]

}

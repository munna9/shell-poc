profile     = "prod1"
region      = "us-east-1"
role_arn    = "arn:aws:iam::317380420770:role/jenkins_agent.stage"
external_id = null

vpc_cidr    = "10.30.0.0/16"
domain_name = "*.dev.ep.shell.com"
dns_zone    = "dev.ep.shell.com"

management_state_bucket = "ne-terraform-staging"
database_state_bucket   = "ne-terraform-dev"
terraform_state_bucket  = "ne-terraform-dev"
management_workspace    = "stage"
database_workspace      = "dev"
network_workspace       = "default"

name                    = "dev"
environment             = "ds"


allowed_cidrs = {
  "jaya_home"            = [ "98.248.136.128/32" ]
  "shell_mobile_connect" = [ "165.225.34.0/23" ]
  "sean_home"            = [ "76.21.5.55/32" ]
  "garrett_home"         = [ "99.174.169.44/32" ]
  "fabio_home"           = [ "73.70.140.144/32" ]
  "kevin_home"           = [ "99.8.65.213/32" ]
  "tamas_home"           = [ "73.93.177.25/32" ]
  "lonnie_home"          = [ "47.219.160.9/32"     ]
  "SENA_RSTOP"           = [ "104.129.195.7/32", "104.129.205.1/32", "165.225.34.187/32"   ]
  "irm_scan"             = [ "208.118.237.224/32", "74.217.87.122/32", "74.217.87.123/32", "74.217.87.78/32", "64.41.200.0/24" ]
}

tags = {
  "Organization"    = "Energy Platform"
  "business_unit"   = "BU:SNEUS"
  "created_by"      = "_"
  "owner"           = "_"
  "department"      = "_"
  "scrum_team"      = "Engineering"
  "application_id"  = "337729"
  "cost_center"     = "290047"
  "version"         = "v.1.0.0"
  "data_owner"      = "Shell Energy Retail Limited - SERL"
  "customer"        = "Shell"
  "project"         = "management"
}


worker_groups_launch_templates = [
  {
        name                  = "cpu"
        kubelet_extra_args    = "--node-labels=name=cpu,nodegroup_name=cpu8x32"
        instance_type         = "m4.4xlarge"
        root_volume_size      = 120
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

  },
  {
        name                  = "cpu"
        kubelet_extra_args    = "--node-labels=name=cpu,nodegroup_name=cpu36x96"
        instance_type         = "c5n.9xlarge"
        root_volume_size      = 120
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

  },
  {
        name                  = "cpu"
        kubelet_extra_args    = "--node-labels=name=cpu,nodegroup_name=k80"
        instance_type         = "p2.xlarge"
        root_volume_size      = 120
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

  },
  {
        name                  = "cpu"
        kubelet_extra_args    = "--node-labels=name=cpu,nodegroup_name=v100"
        instance_type         = "p3.2xlarge"
        root_volume_size      = 120
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

  },
  {
        name                  = "cpu"
        kubelet_extra_args    = "--node-labels=name=cpu,nodegroup_name=nvme"
        instance_type         = "m5d.4xlarge"
        root_volume_size      = 120
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

  }
]

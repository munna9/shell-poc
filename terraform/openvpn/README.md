# OpenVPN Terraform Module

OpenVPN module provision one EC2 instance in a public subnet of your VPC. The instance itself should be used for VPN tunneling.

## Module

The module will create one EC2 instance and attach an Elastic IP to the instance. Additionally it will create security group and one IAM role for the instance.

## OpenVPN AMI

This module requires that an AMI base image with OpenVPN built using the project in AWS account.

That AMI ID is the one that should be used as the value for the required ami_id variable.

## AWS Route53 Service 

If you wish to register the instances FQDN, the AWS Route53 service is also required to be enabled and properly configured.

To register the instances FQDN on AWS Route53 service you need to set the private_zone_id and/or public_zone_id variable(s).

### Variables

The Module takes the arguments below.

| Variable | Description |
| --- | --- |
| source | module location |
| name | Unique name for the module |
| region | The AWS region for the OpenVPN EC2 instance |
| ami | EC2 AMI to use. Note that it has to be Ubuntu 16.04 |
| instance_type | EC2 instance type (t3a.nano should be enough in most cases) |
| key_name | SSH key to use. Note that the key pair need to exist |
| vpc_id | ID of the VPC to use. The VPC has to exist |
| subnet_id | Public subnet for the EC2 instance. The subnet has to exist |
| cidr | IP range that can access any port of the EC2 instance. This can be used in case the instance is used for NAT |
| user_data | commands to execute during launch of the EC2 instance |
| tags | Instance Tags |



### Input Variables

The OpenVPN module exports the following variables

| Variable | Description |
| --- | --- |
| public_ip | The elastic IP address associated with the EC2 instance |
| private_ip | Contains the private IP address |
| ami_id | Amazon Linux AMI ID |
| ebs_region | Region for the EBS volume where we'll store credentials and certificates |
| ebs_size | EBS volume size in GB. 1 should be fine in most cases |
| eip_id | Contains the EIP allocation ID |
| route53_zone | Zone where the vpn will be hosted |
| public_dns_name | The public dns name for the openvpn server |
| sg_id | The security's ID |
|vpc_id | The VPC ID for the security group |
|vpn_allowed_cidrs | List of the subnets to which the VPN clients will be allowed access to |
|vpn_cidr | The subnet for the VPN clients (in CIDR notation) |
|whitelist | List of office IP addresses that you can SSH and non-VPN connected users can reach temporary profile download pages |

### Output Variables

| Variable | Description |
| --- | --- |
| public_ip | The elastic IP address associated with the EC2 instance |
| private_ip | Contains the private IP address |
| fqdn | List of FQDNs of the OpenVPN instance |


## Service Access

This modules provides a security group that will allow access from the OpenVPN instance.

That group will allow access to the following ports to all the AWS EC2 instances that belong to the group.

| Service | Port | Protocol |
|--- | --- | --- |
| SSH | 22 | TCP |
| OpenVPN | 1194 | UDP |


Run the following commands

```bash
terraform init
terraform apply
```



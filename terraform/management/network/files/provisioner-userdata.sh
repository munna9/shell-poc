#!/bin/bash
# variables and defaults
TERRAFORM_VERSION=${1:-0.12.20}
HELM_VERSION=${2:-3.0.3}

# install awscli
yum update -y && yum install python-pip zip unzip curl git docker -y
pip install -U awscli

# install terraform
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/bin/terraform
chmod +x /usr/bin/terraform
rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# install helm
wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
tar -xf helm-v${HELM_VERSION}-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/helm
chmod +x /usr/bin/helm
rm -rf linux-amd64 helm-v${HELM_VERSION}-linux-amd64.tar.gz

# install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
mv kubectl /usr/bin/kubectl
chmod +x /usr/bin/kubectl

curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
mv aws-iam-authenticator /usr/bin/aws-iam-authenticator
chmod +x /usr/bin/aws-iam-authenticator


# intsall amazon-ssm-agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

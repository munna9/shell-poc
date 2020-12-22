#!/bin/bash
# variables and defaults
HELM_VERSION=${1:-3.0.3}

# install awscli
yum update -y && yum install python-pip zip unzip curl git docker -y
pip install -U awscli

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

# intsall amazon-ssm-agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

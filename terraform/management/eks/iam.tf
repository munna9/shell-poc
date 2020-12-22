############################
# IAM Role for EKS Cluster #
############################
resource "aws_iam_role" "eks_cluster" {
  name_prefix = "eks.control.${var.name}.${lookup(var.workspace_shortcode, terraform.workspace, terraform.workspace)}."
  tags = var.tags
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

############################
# IAM Role for EKS Workers #
############################
resource "aws_iam_role" "eks_workers" {
  name_prefix = "eks.workers.${var.name}.${lookup(var.workspace_shortcode, terraform.workspace, terraform.workspace)}."
  tags = var.tags
  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_instance_profile" "eks_workers" {
  name = aws_iam_role.eks_workers.name
  role = aws_iam_role.eks_workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_policy" "eks_workers_alb" {
  name_prefix = "AmazonEKSALBIngressPolicy_"
  path        = "/"
  description = "IAM Policy for EKS to create ALB Ingress"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cognito-idp:DescribeUserPoolClient"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_worker_alb" {
  policy_arn = aws_iam_policy.eks_workers_alb.arn
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_policy" "eks_workers_route53" {
  name_prefix = "AmazonEKSRoute53Policy_"
  path        = "/"
  description = "IAM Policy for EKS to create ALB Ingress"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_worker_route53" {
  policy_arn = aws_iam_policy.eks_workers_route53.arn
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_policy" "eks_workers_autoscaling" {
  name_prefix = "AmazonEKSAutoScalingPolicy_"
  path        = "/"
  description = "IAM Policy for EKS to autoScale worker nodes"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ],
    "Resource": "*",
    "Effect": "Allow"
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_workers_autoscaling" {
  policy_arn = aws_iam_policy.eks_workers_autoscaling.arn
  role       = aws_iam_role.eks_workers.name
}

###################################################
# iam role for jenkins master to read aws secrets #
###################################################

resource "aws_iam_role" "jenkins_master" {
  name_prefix = "jenkins.${var.name}.${lookup(var.workspace_shortcode, terraform.workspace, terraform.workspace)}."
  tags = var.tags
  assume_role_policy = templatefile("${path.module}/files/oidc_assume_role_policy.json",
                         { OIDC_ARN = aws_iam_openid_connect_provider.cluster.arn,
                           OIDC_URL = replace(aws_iam_openid_connect_provider.cluster.url, "https://", ""),
                           NAMESPACE = var.jenkins_deployment.namespace,
                           SA_NAME = var.jenkins_deployment.serviceaccount_master })
  depends_on = [aws_iam_openid_connect_provider.cluster]
}


resource "aws_iam_policy" "jenkins_master" {
  name_prefix = "jenkins.secrets.${lookup(var.workspace_shortcode, terraform.workspace, terraform.workspace)}."
  path        = "/"
  description = "Allow jenkins master to read secrets"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
            "secretsmanager:Describe*",
            "secretsmanager:Get*",
            "secretsmanager:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jenkins_master" {
  policy_arn = aws_iam_policy.jenkins_master.arn
  role       = aws_iam_role.jenkins_master.name
}

###################################################
# iam role for jenkins agent to run terraform #
###################################################

resource "aws_iam_role" "jenkins_agent" {
  name = "jenkins_agent.${lookup(var.workspace_shortcode, terraform.workspace, terraform.workspace)}"
  tags = var.tags
  assume_role_policy = templatefile("${path.module}/files/oidc_assume_role_policy.json",
                         { OIDC_ARN = aws_iam_openid_connect_provider.cluster.arn,
                           OIDC_URL = replace(aws_iam_openid_connect_provider.cluster.url, "https://", ""),
                           NAMESPACE = var.jenkins_deployment.namespace,
                           SA_NAME = var.jenkins_deployment.serviceaccount_agent })
  depends_on = [aws_iam_openid_connect_provider.cluster]
}

resource "aws_iam_role_policy_attachment" "jenkins_agent" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.jenkins_agent.name
}

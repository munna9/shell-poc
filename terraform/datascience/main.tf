module "vpc" {
  source               = "../modules/terraform-aws-vpc"
  cidr                 = var.vpc_cidr
  name                 = "${var.name}.${terraform.workspace}"
  nat_per_az           = false

  subnet_outer_offsets   = [ 1, 1 ]
  subnet_inner_offsets   = [ 1, 1 ]

  transit_gateway_attach      = true
  transit_gateway_id          = data.terraform_remote_state.transit.outputs.transit_gateway_id

  tags = {
    "kubernetes.io/cluster/${var.name}-${terraform.workspace}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}-${terraform.workspace}" = "shared"
    "kubernetes.io/role/elb"                                   = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}-${terraform.workspace}" = "shared"
    "kubernetes.io/role/internal-elb"                          = "1"
  }

  allow_cidrs_default  = {}
}

resource "null_resource" "tag_main_route_table" {
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${element(module.vpc.public_route_tables, 0)} --tags Key=Name,Value=\"public.${var.name}.${terraform.workspace}\" --profile ${var.profile} --region ${var.region} || true"
  }
}


module "eks" {
  source             = "../modules/terraform-aws-eks-managed"
  name               = "${var.name}-${terraform.workspace}"
  subnets            = module.vpc.public_subnets
  vpc_id             = module.vpc.id

  profile = var.profile

  node_groups = [
    {
      name            = "cpu"
      subnets         = module.vpc.private_subnets
      disk_size       = 100
      instance_types  = ["t3.medium"]
      desired_size    = 1
      max_size        = 2
      min_size        = 1
    }
  ]
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    NAME                   = "${var.name}-${terraform.workspace}"
    ENDPOINT               = module.eks.endpoint
    CLUSTER_NAME           = module.eks.id
    CLUSTER_AUTHOTIRY_DATA = module.eks.cluster_auth_data
    AWS_REGION             = var.region
    AWS_PROFILE            = var.profile
  }
}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = "${path.module}/config_output/kubeconfig_${var.name}-${terraform.workspace}"
}

provider "kubernetes" {
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_auth_data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = [ "--region", var.region, "eks", "get-token", "--cluster-name", module.eks.id ]
    env = {
      "AWS_PROFILE" = var.profile
    }
  }
}

resource "kubernetes_namespace" "istio" {
  metadata {
    name = "istio-system"
  }
}

resource "null_resource" "istio" {
  count = 1

  provisioner "local-exec" {
    command = <<-EOF
    helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.4.1/charts/
    helm install istio-init istio.io/istio-init --namespace ${kubernetes_namespace.istio.id} || helm upgrade istio-init istio.io/istio-init --namespace ${kubernetes_namespace.istio.id}
    sleep 60
    helm install istio istio.io/istio --set gateways.istio-ingressgateway.enabled=false --namespace ${kubernetes_namespace.istio.id} || helm upgrade istio  istio.io/istio --namespace ${kubernetes_namespace.istio.id}
    EOF

    environment = {
      AWS_PROFILE      = var.profile
      AWS_REGION       = var.region
      KUBECONFIG       = local_file.kubeconfig.filename
    }
  }

  provisioner "local-exec" {
    when = destroy

    command = <<-EOF
    helm delete istio --namespace ${kubernetes_namespace.istio.id}
    helm delete istio-init --namespace ${kubernetes_namespace.istio.id}
    EOF

    environment = {
      AWS_PROFILE      = var.profile
      AWS_REGION       = var.region
      KUBECONFIG       = local_file.kubeconfig.filename
    }
  }

  depends_on = [ module.eks, module.vpc ]
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "null_resource" "prometheus" {
  count = 1

  provisioner "local-exec" {
    command = <<-EOF
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/
    helm install prometheus stable/prometheus --namespace ${kubernetes_namespace.prometheus.id} --set alertmanager.persistentVolume.storageClass="gp2" --set server.persistentVolume.storageClass="gp2"
    EOF

    environment = {
      AWS_PROFILE      = var.profile
      AWS_REGION       = var.region
      KUBECONFIG       = local_file.kubeconfig.filename
    }
  }

  provisioner "local-exec" {
    when = destroy

    command = <<-EOF
    helm delete prometheus --namespace ${kubernetes_namespace.prometheus.id}
    EOF

    environment = {
      AWS_PROFILE      = var.profile
      AWS_REGION       = var.region
      KUBECONFIG       = local_file.kubeconfig.filename
    }
  }

  depends_on = [ module.eks, module.vpc ]
}

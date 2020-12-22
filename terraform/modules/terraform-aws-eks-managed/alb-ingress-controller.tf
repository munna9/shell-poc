locals {
  alb_ingress_controller_name      = "alb-ingress-controller"
  alb_ingress_controller_namespace = "kube-system"
  alb_ingress_controller_image     = "docker.io/amazon/aws-alb-ingress-controller:v1.1.3"
}

resource "kubernetes_cluster_role" "alb_ingress_controller" {
  metadata {
    name      = local.alb_ingress_controller_name
    labels    = {
      "app.kubernetes.io/name" = local.alb_ingress_controller_name
    }
  }

  rule {
    api_groups = [ "", "extensions" ]
    resources  = [ "configmaps", "endpoints", "events", "ingresses", "ingresses/status", "services" ]
    verbs      = [ "create", "get", "list", "update", "watch", "patch" ]
  }

  rule {
    api_groups = [ "", "extensions" ]
    resources  = [ "nodes", "pods", "secrets", "services", "namespaces" ]
    verbs      = [ "get", "list", "watch" ]
  }
}

resource "kubernetes_service_account" "alb_ingress_controller" {
  metadata {
    namespace = local.alb_ingress_controller_namespace
    name      = local.alb_ingress_controller_name
    labels    = {
      "app.kubernetes.io/name" = local.alb_ingress_controller_name
    }
  }
}

resource "kubernetes_cluster_role_binding" "alb_ingress_controller" {
  metadata {
    name      = local.alb_ingress_controller_name
    labels    = {
      "app.kubernetes.io/name" = local.alb_ingress_controller_name
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.alb_ingress_controller_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.alb_ingress_controller_name
    namespace = local.alb_ingress_controller_namespace
  }
}

resource "kubernetes_deployment" "alb_ingress_controller" {
  metadata {
    namespace = local.alb_ingress_controller_namespace
    name      = local.alb_ingress_controller_name
    labels    = {
      "app.kubernetes.io/name" = local.alb_ingress_controller_name
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = local.alb_ingress_controller_name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = local.alb_ingress_controller_name
        }
      }

      spec {
        container {
          image = local.alb_ingress_controller_image
          name  = local.alb_ingress_controller_name
          args  = ["--ingress-class=alb", "--cluster-name=${aws_eks_cluster.main.id}"]
        }
        service_account_name             = local.alb_ingress_controller_name
        automount_service_account_token  = true
      }
    }
  }
}

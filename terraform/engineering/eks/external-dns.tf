locals {
  external_dns_name      = "externa-dns"
  external_dns_namespace = "kube-system"
  external_dns_image     = "registry.opensource.zalan.do/teapot/external-dns:v0.5.17"
}

resource "kubernetes_cluster_role" "external_dns" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    name      = local.external_dns_name
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "services" ]
    verbs      = [ "get", "watch", "list" ]
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "pods" ]
    verbs      = [ "get", "watch", "list" ]
  }

  rule {
    api_groups = [ "extensions" ]
    resources  = [ "ingresses" ]
    verbs      = [ "get", "watch", "list" ]
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "nodes" ]
    verbs      = [ "list", "watch" ]
  }
}

resource "kubernetes_service_account" "external_dns" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    namespace = local.external_dns_namespace
    name      = local.external_dns_name
  }
}

resource "kubernetes_cluster_role_binding" "external_dns" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    name      = local.external_dns_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.external_dns_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.external_dns_name
    namespace = local.external_dns_namespace
  }
}

resource "kubernetes_deployment" "external_dns" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    namespace = local.external_dns_namespace
    name      = local.external_dns_name
  }

  spec {
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = local.external_dns_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.external_dns_name
        }
      }

      spec {
        container {
          image = local.external_dns_image
          name  = local.external_dns_name
          args  = [ "--source=ingress", "--domain-filter=${var.dns_zone}",  "--provider=aws", "--policy=upsert-only", "--aws-zone-type=public", "--registry=txt", "--txt-owner-id=${module.eks.cluster_id}" ]
        }
        service_account_name             = local.external_dns_name
        automount_service_account_token  = true

        security_context {
          fs_group = 65534
        }
      }
    }
  }
}

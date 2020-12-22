locals {
  metrics_server_name      = "metrics-server"
  metrics_server_namespace = "kube-system"
  metrics_server_image     = "k8s.gcr.io/metrics-server-amd64:v0.3.6"
}

resource "kubernetes_cluster_role" "metrics_server" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    name      = "system:${local.metrics_server_name}"
    labels    = {
      "kubernetes.io/cluster-service"   = "true"
      "addonmanager.kubernetes.io/mode" = "Reconcile"
    }
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "pods", "nodes", "nodes/stats", "namespaces" ]
    verbs      = [ "get", "list", "watch" ]
  }

  rule {
    api_groups = [ "apps" ]
    resources  = [ "deployments" ]
    verbs      = [ "get", "list", "update", "watch" ]
  }
}

resource "kubernetes_cluster_role" "metrics_server_reader" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    name      = "system:aggregated-${local.metrics_server_name}"
    labels    = {
      "rbac.authorization.k8s.io/aggregate-to-view"  = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit"  = "true"
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
      "kubernetes.io/cluster-service"                = "true"
      "addonmanager.kubernetes.io/mode"              = "Reconcile"
    }
  }

  rule {
    api_groups = [ "metrics.k8s.io" ]
    resources  = [ "pods" ]
    verbs      = [ "get", "list", "watch" ]
  }
}

resource "kubernetes_service_account" "metrics_server" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    namespace = local.metrics_server_namespace
    name      = local.metrics_server_name
    labels    = {
      "kubernetes.io/cluster-service"   = "true"
      "addonmanager.kubernetes.io/mode" = "Reconcile"
    }
  }
}

resource "kubernetes_cluster_role_binding" "metrics_server_delegator" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    name      = "${local.metrics_server_name}:system:auth-delegator"
    labels    = {
      "kubernetes.io/cluster-service"   = "true"
      "addonmanager.kubernetes.io/mode" = "Reconcile"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.metrics_server_name
    namespace = local.metrics_server_namespace
  }
}

resource "kubernetes_cluster_role_binding" "metrics_server" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    name      = "system:${local.metrics_server_name}"
    labels    = {
      "kubernetes.io/cluster-service"   = "true"
      "addonmanager.kubernetes.io/mode" = "Reconcile"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:${local.metrics_server_name}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.metrics_server_name
    namespace = local.metrics_server_namespace
  }
}

resource "kubernetes_role_binding" "metrics_server" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    namespace = local.metrics_server_namespace
    name      = "${local.metrics_server_name}-auth-reader"
    labels    = {
      "kubernetes.io/cluster-service"   = "true"
      "addonmanager.kubernetes.io/mode" = "Reconcile"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "extension-apiserver-authentication-reader"
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.metrics_server_name
    namespace = local.metrics_server_namespace
  }
}


resource "kubernetes_api_service" "metrics_server" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    name      = "v1beta1.metrics.k8s.io"
  }
  spec {
    service {
      name      = local.metrics_server_name
      namespace = local.metrics_server_namespace
    }
    group                    = "metrics.k8s.io"
    version                  = "v1beta1"
    insecure_skip_tls_verify = true
    group_priority_minimum   = 100
    version_priority         = 100
  }
}


resource "kubernetes_service" "metrics_server" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    name      = local.metrics_server_name
    namespace = local.metrics_server_namespace
    labels = {
      "kubernetes.io/name" = "metrics-server"
    }
  }
  spec {
    selector = {
      app = local.metrics_server_name
    }
    port {
      name        = "https"
      port        = 443
      protocol    = "TCP"
      target_port = 443
    }
  }
}

resource "kubernetes_deployment" "metrics_server" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  metadata {
    namespace = local.metrics_server_namespace
    name      = local.metrics_server_name
    labels    = {
      app = local.metrics_server_name
    }
  }

  spec {
    selector {
      match_labels = {
        app = local.metrics_server_name
      }
    }

    template {
      metadata {
        name  = local.metrics_server_name
        labels = {
          app = local.metrics_server_name
        }
      }

      spec {
        container {
          image    = local.metrics_server_image
          name     = local.metrics_server_name
          command  = ["/metrics-server", "--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP", "--kubelet-insecure-tls"]
          image_pull_policy = "Always"
          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }
        }

        volume {
          name       = "tmp-dir"
          empty_dir {}
        }

        service_account_name             = local.metrics_server_name
        automount_service_account_token  = true
      }
    }
  }
}

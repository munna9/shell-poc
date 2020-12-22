locals {
  cluster_autoscaler_name      = "cluster-autoscaler"
  cluster_autoscaler_namespace = "kube-system"
  cluster_autoscaler_image     = "gcr.io/google-containers/cluster-autoscaler:v1.14.7"
}

resource "kubernetes_cluster_role" "cluster_autoscaler" {
  metadata {
    name      = local.cluster_autoscaler_name
    labels    = {
      k8s-addon = "${local.cluster_autoscaler_name}.addons.k8s.io"
      k8s-app   = local.cluster_autoscaler_name
    }
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "events", "endpoints" ]
    verbs      = [ "create", "patch" ]
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "pods/eviction" ]
    verbs      = [ "create" ]
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "pods/status" ]
    verbs      = [ "update" ]
  }

  rule {
    api_groups     = [ "" ]
    resources      = [ "endpoints" ]
    resource_names = [ "cluster-autoscaler" ]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "nodes" ]
    verbs      = [ "watch", "list", "get", "update" ]
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "pods", "services", "replicationcontrollers", "persistentvolumeclaims", "persistentvolumes" ]
    verbs      = [ "watch", "list", "get" ]
  }

  rule {
    api_groups = [ "extensions" ]
    resources  = [ "replicasets", "daemonsets" ]
    verbs      = [ "watch", "list", "get" ]
  }

  rule {
    api_groups = [ "policy" ]
    resources  = [ "poddisruptionbudgets" ]
    verbs      = [ "watch", "list" ]
  }

  rule {
    api_groups = [ "apps" ]
    resources  = [ "statefulsets", "replicasets", "daemonsets" ]
    verbs      = [ "watch", "list", "get" ]
  }

  rule {
    api_groups = [ "storage.k8s.io" ]
    resources  = [ "storageclasses", "csinodes" ]
    verbs      = [ "watch", "list", "get" ]
  }

  rule {
    api_groups = [ "batch", "extensions" ]
    resources  = [ "jobs" ]
    verbs      = [ "get", "list", "watch", "patch" ]
  }

  rule {
    api_groups = [ "coordination.k8s.io" ]
    resources  = [ "leases" ]
    verbs      = [ "create" ]
  }

  rule {
    api_groups     = [ "coordination.k8s.io" ]
    resources      = [ "leases" ]
    resource_names = [ "cluster-autoscaler" ]
    verbs          = [ "get", "update" ]
  }
}

resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    namespace = local.cluster_autoscaler_namespace
    name      = local.cluster_autoscaler_name
    labels    = {
      k8s-addon = "${local.cluster_autoscaler_name}.addons.k8s.io"
      k8s-app   = local.cluster_autoscaler_name
    }
  }
}

resource "kubernetes_role" "cluster_autoscaler" {
  metadata {
    namespace = local.cluster_autoscaler_namespace
    name      = local.cluster_autoscaler_name
    labels    = {
      k8s-addon = "${local.cluster_autoscaler_name}.addons.k8s.io"
      k8s-app   = local.cluster_autoscaler_name
    }
  }

  rule {
    api_groups     = [ "" ]
    resources      = ["configmaps"]
    verbs          = [ "create", "list", "watch" ]
  }

  rule {
    api_groups     = [ "" ]
    resources      = [ "configmaps" ]
    resource_names = [ "cluster-autoscaler-status", "cluster-autoscaler-priority-expander" ]
    verbs          = [ "delete", "get", "update", "watch" ]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_autoscaler" {
  metadata {
    name      = local.cluster_autoscaler_name
    labels    = {
      k8s-addon = "${local.cluster_autoscaler_name}.addons.k8s.io"
      k8s-app   = local.cluster_autoscaler_name
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.cluster_autoscaler_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.cluster_autoscaler_name
    namespace = local.cluster_autoscaler_namespace
  }
}

resource "kubernetes_role_binding" "cluster_autoscaler" {
  metadata {
    namespace = local.cluster_autoscaler_namespace
    name      = local.cluster_autoscaler_name
    labels    = {
      k8s-addon = "${local.cluster_autoscaler_name}.addons.k8s.io"
      k8s-app   = local.cluster_autoscaler_name
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = local.cluster_autoscaler_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.cluster_autoscaler_name
    namespace = local.cluster_autoscaler_namespace
  }
}

resource "kubernetes_deployment" "cluster_autoscaler" {
  metadata {
    namespace = local.cluster_autoscaler_namespace
    name      = local.cluster_autoscaler_name
    labels    = {
      app = local.cluster_autoscaler_name
    }
    annotations = {
      "cluster-autoscaler.kubernetes.io/safe-to-evict" = false
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.cluster_autoscaler_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.cluster_autoscaler_name
        }
        annotations = {
          "prometheus.io/scrape" = true
          "prometheus.io/port"   = 8085
        }
      }

      spec {
        container {
          image   = local.cluster_autoscaler_image
          name    = local.cluster_autoscaler_name
          command = [
            "./cluster-autoscaler",
            "--v=4",
            "--stderrthreshold=info",
            "--cloud-provider=aws",
            "--skip-nodes-with-local-storage=false",
            "--expander=least-waste",
            "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${aws_eks_cluster.main.id}",
            "--balance-similar-node-groups",
            "--skip-nodes-with-system-pods=false"
          ]
          resources {
            limits {
              cpu    = "100m"
              memory = "300Mi"
            }
            requests {
              cpu    = "100m"
              memory = "300Mi"
            }
          }

          volume_mount {
            name       = "ssl-certs"
            mount_path = "/etc/ssl/certs/ca-certificates.crt"
            read_only  = true
          }
          image_pull_policy = "Always"
        }

        volume {
          name      = "ssl-certs"
          host_path {
            path = "/etc/ssl/certs/ca-bundle.crt"
          }
        }

        service_account_name             = local.cluster_autoscaler_name
        automount_service_account_token  = true
      }
    }
  }
}

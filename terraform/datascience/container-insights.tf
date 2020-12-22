locals {
  container_insights_name      = "cloudwatch-agent"
  container_insights_namespace = "amazon-cloudwatch"
  container_insights_image     = "amazon/cloudwatch-agent:1.230621.0"
}

resource "kubernetes_namespace" "container_insights" {
  metadata {
    name = local.container_insights_namespace
  }
}

resource "kubernetes_service_account" "container_insights" {
  metadata {
    namespace = kubernetes_namespace.container_insights.id
    name      = local.container_insights_name
  }
}

resource "kubernetes_cluster_role" "container_insights" {
  metadata {
    name = local.container_insights_name
  }

  rule {
    api_groups = [ "" ]
    resources  = ["pods", "nodes", "endpoints"]
    verbs      =  ["list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["replicasets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/proxy"]
    verbs      =  ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/stats", "configmaps", "events"]
    verbs      =  ["create"]
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["cwagent-clusterleader"]
    verbs          = ["get","update"]
  }
}

resource "kubernetes_cluster_role_binding" "container_insights" {
  metadata {
    name = local.container_insights_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.container_insights_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.container_insights_name
    namespace = kubernetes_namespace.container_insights.id
  }
}

resource "kubernetes_config_map" "container_insights" {
  metadata {
    namespace = kubernetes_namespace.container_insights.id
    name      = local.container_insights_name
  }

  data = {
    "cwagentconfig.json" = templatefile("${path.module}/templates/cwagentconfig.json.tpl", { cluster_name = module.eks.id })
  }
}

resource "kubernetes_daemonset" "container_insights" {
  metadata {
    namespace = kubernetes_namespace.container_insights.id
    name      = local.container_insights_name
  }

  spec {
    selector {
      match_labels = {
        name = local.container_insights_name
      }
    }

    template {
      metadata {
        labels = {
          name = local.container_insights_name
        }
      }

      spec {
        container {
          image = local.container_insights_image
          name  = local.container_insights_name

          resources {
            limits {
              cpu    = "200m"
              memory = "200Mi"
            }
            requests {
              cpu    = "200m"
              memory = "200Mi"
            }
          }

          env {
            name  = "HOST_IP"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }

          env {
            name  = "HOST_IP"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }

          env {
            name  = "HOST_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name  = "K8S_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name  = "CI_VERSION"
            value = "k8s/1.0.1"
          }

          volume_mount {
            name       = "cwagentconfig"
            mount_path = "/etc/cwagentconfig"
          }

          volume_mount {
            name       = "rootfs"
            mount_path = "/rootfs"
            read_only  = true
          }

          volume_mount {
            name       = "dockersock"
            mount_path = "/var/run/docker.sock"
            read_only  = true
          }

          volume_mount {
            name       = "varlibdocker"
            mount_path = "/var/lib/docker"
            read_only  = true
          }

          volume_mount {
            name       = "sys"
            mount_path = "/sys"
            read_only  = true
          }

          volume_mount {
            name       = "devdisk"
            mount_path = "/dev/disk"
            read_only  = true
          }
        }

        volume {
          name      = "cwagentconfig"
          config_map {
            name = local.container_insights_name
          }
        }

        volume {
          name      = "rootfs"
          host_path {
            path = "/"
          }
        }

        volume {
          name      = "dockersock"
          host_path {
            path = "/var/run/docker.sock"
          }
        }

        volume {
          name      = "varlibdocker"
          host_path {
            path = "/var/lib/docker"
          }
        }

        volume {
          name      = "sys"
          host_path {
            path = "/sys"
          }
        }

        volume {
          name      = "devdisk"
          host_path {
            path = "/dev/disk"
          }
        }

        service_account_name             = local.container_insights_name
        automount_service_account_token  = true
      }
    }
  }
}

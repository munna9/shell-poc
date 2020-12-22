locals {
  fluentd_name      = "fulentd"
  fluentd_namespace = "amazon-cloudwatch"
  fluentd_image     = "fluent/fluentd-kubernetes-daemonset:v1.7.3-debian-cloudwatch-1.0"
}

resource "kubernetes_config_map" "cluster_info" {
  metadata {
    name = "cluster-info"
    namespace = kubernetes_namespace.container_insights.id
  }

  data = {
    "cluster.name" = module.eks.id
    "logs.region"  = var.region
  }
}

resource "kubernetes_service_account" "fluentd" {
  metadata {
    namespace = kubernetes_namespace.container_insights.id
    name      = local.fluentd_name
  }
}

resource "kubernetes_cluster_role" "fluentd" {
  metadata {
    name = local.fluentd_name
  }

  rule {
    api_groups = [ "" ]
    resources  = ["namespaces", "pods", "pods/logs"]
    verbs      =  ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "fluentd" {
  metadata {
    name = local.fluentd_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.fluentd_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.fluentd_name
    namespace = kubernetes_namespace.container_insights.id
  }
}

resource "kubernetes_config_map" "fluentd" {
  metadata {
    namespace = kubernetes_namespace.container_insights.id
    name      = local.fluentd_name
    labels    = {
        k8s-app = "fluentd-cloudwatch"
    }
  }

  data = {
    "fluent.conf" = templatefile("${path.module}/templates/fluentd.conf.tpl", {})
    "containers.conf" = templatefile("${path.module}/templates/containers.conf.tpl", {})
    "systemd.conf" = templatefile("${path.module}/templates/systemd.conf.tpl", {})
    "host.conf" = templatefile("${path.module}/templates/host.conf.tpl", {})
  }
}

resource "kubernetes_daemonset" "fluentd" {
  metadata {
    namespace = kubernetes_namespace.container_insights.id
    name      = local.fluentd_name
  }

  spec {
    selector {
      match_labels = {
        name = local.fluentd_name
      }
    }

    template {
      metadata {
        labels = {
          name = local.fluentd_name
        }
      }

      spec {
        init_container {
          image = "busybox"
          name  = "copy-fluentd-config"
          command = ["sh", "-c", "cp /config-volume/..data/* /fluentd/etc"]
          volume_mount {
              name = "config-volume"
              mount_path = "/config-volume"
          }
          volume_mount {
              name = "fluentdconf"
              mount_path = "/fluentd/etc"
          }
        }

        init_container {
          image = "busybox"
          name  = "update-log-driver"
          command = ["sh", "-c", ""]
        }

        container {
          image = local.fluentd_image
          name  = local.fluentd_name

          resources {
            limits {
              memory = "400Mi"
            }
            requests {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          env {
            name  = "REGION"
            value_from {
              config_map_key_ref {
                name = "cluster-info"
                key = "logs.region"
              }
            }
          }

           env {
            name  = "CLUSTER_NAME"
            value_from {
              config_map_key_ref {
                name = "cluster-info"
                key = "cluster.name"
              }
            }
          }

          env {
            name  = "CI_VERSION"
            value = "k8s/1.0.1"
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/config-volume"
          }

          volume_mount {
            name       = "fluentdconf"
            mount_path = "/fluentd/etc"
          }

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }

          volume_mount {
            name       = "varlibdockercontainers"
            mount_path = "/var/lib/docker/containers"
            read_only  = true
          }

          volume_mount {
            name       = "runlogjournal"
            mount_path = "/run/log/journal"
            read_only  = true
          }

          volume_mount {
            name       = "dmesg"
            mount_path = "/var/log/dmesg"
            read_only  = true
          }
        }

        volume {
          name      = "config-volume"
          config_map {
            name = "fluentd-config"
          }
        }

        volume {
          name      = "fluentdconf"
          empty_dir {}
        }

        volume {
          name      = "varlog"
          host_path {
            path = "/var/log"
          }
        }

        volume {
          name      = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }

        volume {
          name      = "runlogjournal"
          host_path {
            path = "/run/log/journal"
          }
        }

        volume {
          name      = "dmesg"
          host_path {
            path = "/var/log/dmesg"
          }
        }

        service_account_name             = local.fluentd_name
        automount_service_account_token  = true
      }
    }
  }
}

locals {
  efs_provisioner_name      = "efs-provisioner"
  efs_provisioner_namespace = "kube-system"
  efs_provisioner_image     = "quay.io/external_storage/efs-provisioner:latest"
}

resource "aws_efs_file_system" "main" {
  creation_token = "${var.name}.${terraform.workspace}"

  tags = merge({
    Name         = "${var.name}.${terraform.workspace}"
    Envinronment = terraform.workspace
  }, var.tags)
}

resource "aws_efs_mount_target" "main" {
  count           = length(local.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = element(local.vpc.private_subnets, count.index)
  security_groups = [ aws_security_group.efs.id,  local.vpc.default_sg ]
}

resource "kubernetes_config_map" "efs_provisioner" {
  depends_on = [ module.eks ]
  metadata {
    name      = "efs-provisioner"
    namespace = "kube-system"
  }

  data = {
    "file.system.id"   = aws_efs_file_system.main.id
    "aws.region"       = data.aws_region.current.name
    "provisioner.name" = "aws-efs"
    "dns.name"         = ""
  }
}

resource "kubernetes_storage_class" "efs_provisioner" {
  depends_on = [ module.eks ]
  metadata {
    name = "aws-efs"
    annotations = { "storageclass.kubernetes.io/is-default-class" = true }
  }
  storage_provisioner = "aws-efs"
  reclaim_policy      = "Retain"
}

resource "null_resource" "gp" {
  depends_on = [ module.eks ]
  provisioner "local-exec" {
    command = "kubectl patch storageclass  gp2 -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}'"

    environment = {
      KUBECONFIG = "${path.root}/config_output/kubeconfig_${var.name}-${terraform.workspace}"
    }
  }
}

resource "kubernetes_cluster_role" "efs_provisioner" {
  depends_on = [ module.eks ]
  metadata {
    name      = local.efs_provisioner_name
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "persistentvolumes" ]
    verbs      = [ "get", "list", "watch", "create", "delete" ]
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "persistentvolumeclaims" ]
    verbs      = [ "get", "list", "watch", "update" ]
  }

  rule {
    api_groups = [ "storage.k8s.io" ]
    resources  = [ "storageclasses" ]
    verbs      = [ "get", "list", "watch" ]
  }

  rule {
    api_groups = [ "" ]
    resources  = [ "events" ]
    verbs      = [ "create", "update", "patch" ]
  }
}

resource "kubernetes_service_account" "efs_provisioner" {
  depends_on = [ module.eks ]
  metadata {
    namespace = local.efs_provisioner_namespace
    name      = local.efs_provisioner_name
  }
}

resource "kubernetes_cluster_role_binding" "efs_provisioner" {
  depends_on = [ module.eks ]
  metadata {
    name      = local.efs_provisioner_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.efs_provisioner_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.efs_provisioner_name
    namespace = local.efs_provisioner_namespace
  }
}

resource "kubernetes_role" "efs_provisioner" {
  depends_on = [ module.eks ]
  metadata {
    namespace = local.efs_provisioner_namespace
    name      = local.efs_provisioner_name
  }

  rule {
    api_groups     = [ "" ]
    resources      = [ "endpoints" ]
    verbs          = [ "get", "list", "watch", "create", "update", "patch" ]
  }
}

resource "kubernetes_role_binding" "efs_provisioner" {
  depends_on = [ module.eks ]
  metadata {
    namespace = local.efs_provisioner_namespace
    name      = local.efs_provisioner_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = local.efs_provisioner_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.efs_provisioner_name
    namespace = local.efs_provisioner_namespace
  }
}

resource "kubernetes_deployment" "efs_provisioner" {
  depends_on = [ module.eks ]
  metadata {
    namespace = local.efs_provisioner_namespace
    name      = local.efs_provisioner_name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.efs_provisioner_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.efs_provisioner_name
        }
        annotations = {
          "prometheus.io/scrape" = true
          "prometheus.io/port"   = 8085
        }
      }

      spec {
        container {
          image   = local.efs_provisioner_image
          name    = local.efs_provisioner_name

          env {
            name  = "FILE_SYSTEM_ID"
            value_from {
              config_map_key_ref {
                name = local.efs_provisioner_name
                key  = "file.system.id"
              }
            }
          }

          env {
            name  = "AWS_REGION"
            value_from {
              config_map_key_ref {
                name = local.efs_provisioner_name
                key  = "aws.region"
              }
            }
          }

          env {
            name  = "DNS_NAME"
            value_from {
              config_map_key_ref {
                name = local.efs_provisioner_name
                key  = "dns.name"
              }
            }
          }

          env {
            name  = "PROVISIONER_NAME"
            value_from {
              config_map_key_ref {
                name = local.efs_provisioner_name
                key  = "provisioner.name"
              }
            }
          }

          volume_mount {
            name       = "pv-volume"
            mount_path = "/persistentvolumes"
          }

          image_pull_policy = "Always"
        }

        volume {
          name      = "pv-volume"
          nfs {
            server = aws_efs_file_system.main.dns_name
            path   = "/"
          }
        }

        service_account_name             = local.efs_provisioner_name
        automount_service_account_token  = true
      }
    }
  }
}

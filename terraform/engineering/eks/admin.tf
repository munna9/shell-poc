resource "kubernetes_cluster_role" "cluster_admin" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  count     = length(var.map_roles)

  metadata {
    name      = "eks_admininistrator"
  }
  rule {
    api_groups     = [ "*" ]
    resources      = [ "*" ]
    verbs          = [ "*" ]
  }

  rule {
    non_resource_urls = [ "*" ]
    verbs             = [ "*" ]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_admin" {
  depends_on = [aws_security_group_rule.management_private_cluster]
  count     = length(var.map_roles)
  metadata {
    name      = "eks_admininistrator"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "eks_admininistrator"
  }

  subject {
    kind      = "Group"
    name      = "system:eks-administrators"
    api_group  = "rbac.authorization.k8s.io"
  }
}

output "id" {
  value = aws_eks_cluster.main.id
}

output "endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_auth_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

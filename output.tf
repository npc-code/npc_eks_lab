output "endpoint" {
  value = aws_eks_cluster.test_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.test_cluster.certificate_authority[0].data
}
output "endpoint" {
  value = aws_eks_cluster.test_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.test_cluster.certificate_authority[0].data
}

output "vpc_config_sg" {
  value = aws_eks_cluster.test_cluster.vpc_config[0].cluster_security_group_id
}

output "created_cluster_sg_from_module" {
  value = module.network.cluster_sg
}

output "alb_security_group_id" {
  value = module.network.alb_sg
}

output "pod_security_group_id" {
  value = module.network.pod_sg
}
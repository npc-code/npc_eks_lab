locals {
  sts_principal                 = "sts.${data.aws_partition.current.dns_suffix}"
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler-chart"
}
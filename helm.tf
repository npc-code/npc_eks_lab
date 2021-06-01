provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.test_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.test_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}




resource "helm_release" "metric-server" {
  name       = "metric-server"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  namespace  = "kube-system"
  set {
    name  = "apiService.create"
    value = "true"
  }
}

resource "helm_release" "auto-scaler" {
  name       = "auto-scaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = local.k8s_service_account_name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.autoscaler.arn
  }

}
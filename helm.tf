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

resource "helm_release" "alb-ingress" {
  name       = "alb-ingress"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  dynamic "set" {
    for_each = {
      "clusterName"                                               = var.cluster_name
      "serviceAccount.create"                                     = true
      "serviceAccount.name"                                       = local.k8s_alb_service_account_name
      "region"                                                    = data.aws_region.current.name
      "vpcId"                                                     = module.network.vpc_id
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.alb_ingress.arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }


  #set {
  #  name  = "serviceAccount.create"
  #  value = true
  #}

  #set {
  #    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #    value = aws_iam_role.alb_ingress.arn
  #}

  #set {
  #  name  = "clusterName"
  #  value = var.cluster_name
  #}

  #set {
  ##  name  = "serviceAccount.name"
  #  value = local.k8s_alb_service_account_name
  #}

  #set {
  #    name = "region"
  #    value = data.aws_region.current.name
  #}

  #set {
  #    name  = "vpcId"
  #    value = module.network.vpc_id 
  #}
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
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
}

resource "helm_release" "auto-scaler" {
  name       = "auto-scaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  dynamic "set" {
    for_each = {
      "awsRegion"                                                      = data.aws_region.current.name
      "autoDiscovery.clusterName"                                      = var.cluster_name
      "rbac.create"                                                    = true
      "rbac.serviceAccount.create"                                     = true
      "rbac.serviceAccount.name"                                       = local.k8s_service_account_name
      "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.autoscaler.arn
    }

    content {
      name  = set.key
      value = set.value
    }
  }
}
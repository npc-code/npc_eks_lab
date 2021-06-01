#more reading needed here.
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = [local.sts_principal]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  url             = flatten(concat(aws_eks_cluster.test_cluster[*].identity[*].oidc.0.issuer, [""]))[0]

  tags = {
    Name = "${var.cluster_name}-eks-irsa"
  }
}

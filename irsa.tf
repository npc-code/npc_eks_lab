#more reading here.

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = [local.sts_principal]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  url             = flatten(concat(aws_eks_cluster.test_cluster[*].identity[*].oidc.0.issuer, [""]))[0]

  tags = {
    Name = "${var.cluster_name}-eks-irsa"
  }
}

#module "iam_assumable_role_admin" {
#  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#  version                       = "3.6.0"
#  create_role                   = true
#  role_name                     = "cluster-autoscaler"
#provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
#  provider_url                  = replace(flatten(concat(aws_eks_cluster.test_cluster[*].identity[*].oidc.0.issuer, [""]))[0], "https://", "")
#role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
#  role_policy_arns              = [aws_iam_policy.cluster_autoscaler_policy.arn]
#  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
#}
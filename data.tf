data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = var.cluster_name
}

data "aws_region" "current" {}

data "aws_partition" "current" {}
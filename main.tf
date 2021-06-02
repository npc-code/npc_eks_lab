provider "aws" {
  region  = var.region
  profile = var.profile

  default_tags {
    tags = {
      Environment = "NicCeynowaRearcLab-${var.environment}"
      Owner       = "NicCeynowaRearc"
      Project     = "eks_lab"
    }
  }
}

module "network" {
  source           = "./network"
  base_network     = var.base_network
  network_mask     = var.network_mask
  subnet_mask      = var.subnet_mask
  azs              = data.aws_availability_zones.azs.names
  eks_cluster_name = var.cluster_name
  eks_generated_sg = aws_eks_cluster.test_cluster.vpc_config[0].cluster_security_group_id
  external_ip      = var.external_ip
}

resource "aws_eks_cluster" "test_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = var.eks_version


  vpc_config {
    endpoint_private_access = true
    security_group_ids      = [module.network.cluster_sg]
    subnet_ids              = module.network.eni_subnets
    public_access_cidrs     = [var.external_ip]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.test-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.test-AmazonEKSVPCResourceController,
  ]
}






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

data "aws_availability_zones" "azs" {
  state = "available"
}

module "network" {
  source           = "./network"
  base_network     = var.base_network
  network_mask     = var.network_mask
  subnet_mask      = var.subnet_mask
  azs              = data.aws_availability_zones.azs.names
  eks_cluster_name = var.cluster_name
  eks_generated_sg = aws_eks_cluster.test_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_eks_cluster" "test_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn


  vpc_config {
    endpoint_private_access = true
    security_group_ids  = [module.network.cluster_sg, module.network.node_sg]
    subnet_ids          = module.network.eni_subnets
    public_access_cidrs = ["74.69.167.125/32"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.test-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.test-AmazonEKSVPCResourceController,
  ]
}

# Nodes in private subnets
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.test_cluster.name
  node_group_name = "${var.cluster_name}-node-group-main-${var.environment}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.network.private_subnets

  #ami_type        = var.ami_type
  #disk_size       = var.disk_size
  #instance_types  = var.instance_types

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  tags = {
    Name = "${var.cluster_name}-node-group-main-${var.environment}"
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only,
  ]
}





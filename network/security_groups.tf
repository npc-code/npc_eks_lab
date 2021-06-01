#security group to pass to cluster.  this will be in addition to the automatically created sg by the eks service
resource "aws_security_group" "eks_cluster" {
  name        = "eksClusterSG"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.cluster_vpc.id

  tags = {
    Name = var.eks_cluster_name
  }
}

#security groups for nodes outside of pure managed node groups
resource "aws_security_group" "eks_nodes" {
  name        = "eksNodeSG"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.cluster_vpc.id
  #if we are using this, we might want to remove the owned tag, since the created security group is already tagged as such
  tags = {
    Name                                            = "eksNodeSGMain"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

#eks cluster alb security group
resource "aws_security_group" "eks_cluster_alb" {
  name        = "eksClusterALB_SG"
  description = "security group for alb"
  vpc_id      = aws_vpc.cluster_vpc.id

  tags = {
    Name = "${var.eks_cluster_name}-alb"
  }
}




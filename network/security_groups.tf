#security group to pass to cluster.  this will be in addition to the automatically created sg by the eks service
resource "aws_security_group" "eks_cluster" {
  name        = "eksClusterSG"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.cluster_vpc.id

  tags = {
    Name = var.eks_cluster_name
  }
}

resource "aws_security_group_rule" "general_cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
  protocol          = "-1"
}

resource "aws_security_group_rule" "workers_to_plane" {
  description              = "allow pods to talk to api endpoint"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}


resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress"
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
#should try to work with minimal egress rule (443 to cluster)
resource "aws_security_group_rule" "worker_node_outbound" {
  description       = "worker egress"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.eks_nodes.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
}

resource "aws_security_group_rule" "node_to_node" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_ingress_generated_sg" {
  description              = "allow communication from managed nodes not using custom launch template"
  from_port                = 0
  protocol                 = -1
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = var.eks_generated_sg
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_egress_generated_sg" {
  description              = "allow communication from custom managed nodes to purely managed nodes"
  from_port                = 0
  protocol                 = -1
  security_group_id        = var.eks_generated_sg
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 0
  type                     = "ingress"
}
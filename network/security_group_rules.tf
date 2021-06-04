#should try to work with minimal egress rule (443 to cluster from worker group)


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

resource "aws_security_group_rule" "eks_alb_to_nodes" {
    description              = "allow communication from alb to nodes in generated sg."
  from_port                = 30000
  protocol                 = -1
  security_group_id        = var.eks_generated_sg
  source_security_group_id = aws_security_group.eks_cluster_alb.id
  to_port                  = 32767
  type                     = "ingress"

}

resource "aws_security_group_rule" "eks_alb_to_custom_nodes" {
    description              = "allow communication from alb to nodes in generated sg."
  from_port                = 30000
  protocol                 = -1
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster_alb.id
  to_port                  = 32767
  type                     = "ingress"
}

resource "aws_security_group_rule" "alb_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = [var.external_ip]
  security_group_id = aws_security_group.eks_cluster_alb.id
  protocol          = "tcp"
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_alb.id
  protocol          = "-1"
}
output "eni_subnets" {
  value = aws_subnet.eni_subnets.*.id
}

output "alb_sg" {
  value = aws_security_group.eks_cluster_alb.id
}

output "cluster_sg" {
  value = aws_security_group.eks_cluster.id
}

output "node_sg" {
  value = aws_security_group.eks_nodes.id
}

output "pod_sg" {
  value = aws_security_group.pod_security_group.id
}

output "public_subnets" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnets.*.id
}

output "vpc_id" {
  value = aws_vpc.cluster_vpc.id
}
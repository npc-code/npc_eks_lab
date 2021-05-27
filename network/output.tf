output "control_plane_subnets" {
  value = aws_subnet.control_plane_subnets.*.id
}

output "cluster_sg" {
  value = aws_security_group.eks_cluster.id
}

output "node_sg" {
  value = aws_security_group.eks_nodes.id
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
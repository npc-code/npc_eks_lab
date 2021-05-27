resource "aws_vpc" "cluster_vpc" {
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = local.base_cidr
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags = {
    "Name" = "cluster_vpc"
  }
}

#needs to be tagged a certain way for cluster interaction
resource "aws_subnet" "public_subnets" {
  count             = 3
  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = cidrsubnet(local.base_cidr, local.new_bits, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    "Name" = "public-subnet-${count.index}"
  }
}

#needs to be tagged a certain way for nodes
resource "aws_subnet" "private_subnets" {
  count             = 3
  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = cidrsubnet(local.base_cidr, local.new_bits, count.index + 3)
  availability_zone = element(var.azs, count.index)
  tags = {
    "Name"                                          = "private-subnet-${count.index}"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = 1
  }
}

resource "aws_subnet" "control_plane_subnets" {
  count             = 3
  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = cidrsubnet(local.base_cidr, local.new_bits, count.index + 6)
  availability_zone = element(var.azs, count.index)
  tags = {
    "Name" = "control-plane-subnet-${count.index}"
  }

}
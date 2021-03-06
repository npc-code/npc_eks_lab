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
  count                   = local.num_subnets
  vpc_id                  = aws_vpc.cluster_vpc.id
  cidr_block              = cidrsubnet(local.base_cidr, local.new_bits, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name"                                          = "public-subnet-${count.index}"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = 1
  }
}

#needs to be tagged a certain way for nodes
resource "aws_subnet" "private_subnets" {
  count                   = local.num_subnets
  vpc_id                  = aws_vpc.cluster_vpc.id
  cidr_block              = cidrsubnet(local.base_cidr, local.new_bits, count.index + local.num_subnets)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name"                            = "private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = 1
  }
}

#as per documentation, these subnets that will be passed to the cluster resource should be smaller
#need to figure out how to do this properly in the locals block.
resource "aws_subnet" "eni_subnets" {
  count             = local.num_subnets
  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = cidrsubnet(local.base_cidr, local.new_bits, count.index + local.num_subnets + local.num_subnets)
  availability_zone = element(var.azs, count.index)
  tags = {
    "Name" = "eni-subnet-${count.index}"
  }

}
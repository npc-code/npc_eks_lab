#resource "aws_eip" "nat_gw_eip" {}

#resource "aws_nat_gateway" "minimal_nat_gateway" {
#    allocation_id = aws_eip.nat_gw_eip.id
#    subnet_id = aws_subnet.public_subnets.0.id   
#}

#resource "aws_route_table" "minimal_private_route_table" {
#  vpc_id = aws_vpc.cluster_vpc.id
#  route {
#      cidr_block = "0.0.0.0/0"
#      nat_gateway_id = aws_nat_gateway.minimal_nat_gateway.id
#  }

#  tags = {
#    Name = "private-route"
#  }
#}

#resource "aws_route_table_association" "minimal_private_route_assoc" {
#    count = 3
#    subnet_id = element(aws_subnet.private_subnets.*.id, count.index)
#   route_table_id = aws_route_table.minimal_private_route_table.id
#}

#running into issues creating the NAT within the test account, may be at full EIP allocation.
#will use an internet gateway instead for these subnets, purely for testing purposes
resource "aws_route_table_association" "ig_route_testing" {
  count          = local.num_subnets
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.internet_route.id
}

resource "aws_route_table_association" "ig_route" {
  count          = local.num_subnets
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.internet_route.id
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cluster_vpc.id
}

resource "aws_route_table" "internet_route" {
  vpc_id = aws_vpc.cluster_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "internet-route-table"
  }
}

resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  vpc_id         = aws_vpc.cluster_vpc.id
  route_table_id = aws_route_table.internet_route.id
}
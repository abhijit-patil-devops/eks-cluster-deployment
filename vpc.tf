resource "aws_vpc" "our_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "our-vpc"
  }
}

resource "aws_internet_gateway" "our_vpc_igw" {
  vpc_id = aws_vpc.our_vpc.id

  tags = {
    Name = "our-vpc-igw"
  }
}

resource "aws_subnet" "our_vpc_public" {
  count                   = 3
  vpc_id                  = aws_vpc.our_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.our_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["ap-south-1a", "ap-south-1b", "ap-south-1c"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                     = "our-vpc-public-${count.index + 1}"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/project-cluster"  = "shared"
  }
}

resource "aws_route_table" "our_vpc_public_rt" {
  vpc_id = aws_vpc.our_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.our_vpc_igw.id
  }

  tags = {
    Name = "our-vpc-public-rt"
  }
}

resource "aws_route_table_association" "our_vpc_public_rt_assoc" {
  count          = 3
  subnet_id      = aws_subnet.our_vpc_public[count.index].id
  route_table_id = aws_route_table.our_vpc_public_rt.id
}
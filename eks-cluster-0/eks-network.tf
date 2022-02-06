#module "eks" {
#  source  = "terraform-aws-modules/eks/aws"
#  version = "18.3.1"
#  # insert the 12 required variables here
#  cluster_name                    = "my-cluster"
#  cluster_version                 = "1.21"
#  cluster_endpoint_private_access = true
#  cluster_endpoint_public_access  = true
#
#  cluster_addons = {
#    coredns = {
#      resolve_conflicts = "OVERWRITE"
#    }
#    kube-proxy = {}
#    vpc-cni = {
#      resolve_conflicts = "OVERWRITE"
#    }
#  }
#
#  vpc_id     = "vpc-1234556abcdef"
#  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
#}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "eks-vpc-cluster-0" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc-cluster-0"
  }
}

resource "aws_internet_gateway" "eks-igw-cluster-0" {
  vpc_id = aws_vpc.eks-vpc-cluster-0.id
  depends_on = [
    aws_vpc.eks-vpc-cluster-0
  ]
}

resource "aws_subnet" "eks-sbn-public-01-cluster-0" {
  vpc_id     = aws_vpc.eks-vpc-cluster-0.id
  cidr_block = "192.168.0.0/18"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "eks-sbn-public-01-cluster-0"
    "kubernetes.io/role/elb" = 1
  }
  depends_on = [
    aws_vpc.eks-vpc-cluster-0
  ]
}

resource "aws_subnet" "eks-sbn-public-02-cluster-0" {
  vpc_id     = aws_vpc.eks-vpc-cluster-0.id
  cidr_block = "192.168.64.0/18"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "eks-sbn-public-02-cluster-0"
    "kubernetes.io/role/elb" = 1
  }
  depends_on = [
    aws_vpc.eks-vpc-cluster-0
  ]
}


resource "aws_subnet" "eks-sbn-private-01-cluster-0" {
  vpc_id     = aws_vpc.eks-vpc-cluster-0.id
  cidr_block = "192.168.128.0/18"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "eks-sbn-private-01-cluster-0"
    "kubernetes.io/role/elb" = 1
  }
  depends_on = [
    aws_vpc.eks-vpc-cluster-0
  ]
}

resource "aws_subnet" "eks-sbn-private-02-cluster-0" {
  vpc_id     = aws_vpc.eks-vpc-cluster-0.id
  cidr_block = "192.168.192.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "eks-sbn-private-02-cluster-0"
    "kubernetes.io/role/elb" = 1
  }
  depends_on = [
    aws_vpc.eks-vpc-cluster-0
  ]
}

resource "aws_eip" "eks-eip-01-cluster-0" {
  vpc      = true
}

resource "aws_eip" "eks-eip-02-cluster-0" {
  vpc      = true
}

resource "aws_nat_gateway" "eks-private-ngw-01-cluster-0" {
  allocation_id = aws_eip.eks-eip-01-cluster-0.id
  subnet_id     = aws_subnet.eks-sbn-public-01-cluster-0.id

  tags = {
    Name = "eks-private-ngw-01-cluster-0"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.eks-igw-cluster-0,aws_vpc.eks-vpc-cluster-0,aws_subnet.eks-sbn-public-01-cluster-0]
}

resource "aws_nat_gateway" "eks-private-ngw-02-cluster-0" {
  allocation_id = aws_eip.eks-eip-02-cluster-0.id
  subnet_id     = aws_subnet.eks-sbn-public-02-cluster-0.id

  tags = {
    Name = "eks-private-ngw-02-cluster-0"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.eks-igw-cluster-0,aws_vpc.eks-vpc-cluster-0,aws_subnet.eks-sbn-public-02-cluster-0]
}

resource "aws_route_table" "eks-public-rt-cluster-0" {
  vpc_id = aws_vpc.eks-vpc-cluster-0.id

  route = []

  tags = {
    Name = "eks-public-rt-cluster-0"
  }
  depends_on = [
    aws_vpc.eks-vpc-cluster-0
  ]
}

resource "aws_route_table" "eks-private-rt-01-cluster-0" {
  vpc_id = aws_vpc.eks-vpc-cluster-0.id

  route = []

  tags = {
    Name = "eks-private-rt-01-cluster-0"
  }
  depends_on = [
    aws_vpc.eks-vpc-cluster-0
  ]
}

resource "aws_route_table" "eks-private-rt-02-cluster-0" {
  vpc_id = aws_vpc.eks-vpc-cluster-0.id

  route = []

  tags = {
    Name = "eks-private-rt-02-cluster-0"
  }
  depends_on = [
    aws_vpc.eks-vpc-cluster-0
  ]
}

resource "aws_route" "eks-public-r-cluster-0" {
  route_table_id            =  aws_route_table.eks-public-rt-cluster-0.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.eks-igw-cluster-0.id
  depends_on                = [aws_route_table.eks-public-rt-cluster-0,aws_internet_gateway.eks-igw-cluster-0]
}

resource "aws_route" "eks-private-r-01-cluster-0" {
  route_table_id            =  aws_route_table.eks-private-rt-01-cluster-0.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.eks-private-ngw-01-cluster-0.id
  depends_on                = [aws_route_table.eks-private-rt-01-cluster-0,aws_nat_gateway.eks-private-ngw-01-cluster-0]
}

resource "aws_route" "eks-private-r-02-cluster-0" {
  route_table_id            =  aws_route_table.eks-private-rt-02-cluster-0.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.eks-private-ngw-02-cluster-0.id
  depends_on                = [aws_route_table.eks-private-rt-02-cluster-0,aws_nat_gateway.eks-private-ngw-02-cluster-0]
}

resource "aws_route_table_association" "eks-public-ascrt-01-cluster-0" {
  subnet_id      = aws_subnet.eks-sbn-public-01-cluster-0.id
  route_table_id = aws_route_table.eks-public-rt-cluster-0.id
  depends_on = [
    aws_subnet.eks-sbn-public-01-cluster-0,
    aws_route_table.eks-public-rt-cluster-0
  ]
}

resource "aws_route_table_association" "eks-public-ascrt-02-cluster-0" {
  subnet_id      = aws_subnet.eks-sbn-public-02-cluster-0.id
  route_table_id = aws_route_table.eks-public-rt-cluster-0.id
  depends_on = [
    aws_subnet.eks-sbn-public-02-cluster-0,
    aws_route_table.eks-public-rt-cluster-0
  ]
}

resource "aws_route_table_association" "eks-private-ascrt-01-cluster-0" {
  subnet_id      = aws_subnet.eks-sbn-private-01-cluster-0.id
  route_table_id = aws_route_table.eks-private-rt-01-cluster-0.id
  depends_on = [
    aws_subnet.eks-sbn-private-01-cluster-0,
    aws_route_table.eks-private-rt-01-cluster-0
  ]
}

resource "aws_route_table_association" "eks-private-ascrt-02-cluster-0" {
  subnet_id      = aws_subnet.eks-sbn-private-02-cluster-0.id
  route_table_id = aws_route_table.eks-private-rt-02-cluster-0.id
  depends_on = [
    aws_route_table.eks-private-rt-02-cluster-0,
    aws_subnet.eks-sbn-private-02-cluster-0
  ]
}

resource "aws_security_group" "eks-controlplane-sg-cluster-0" {
  name        = "eks-controlplane-sg-cluster-0"
  description = "eks controlplane sg cluster 0"
  vpc_id      = aws_vpc.eks-vpc-cluster-0.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "eks-controlplane-sg-cluster-0"
  }
  depends_on = [
    aws_vpc.eks-vpc-cluster-0
  ]
}
resource "aws_vpc" "eks" {
  cidr_block       = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.eks.id
  count     = length(var.public_subnet_cidr)
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-${count.index + 1}"
    #each subnet will be named eks-public-subnet-1, eks-public-subnet-2, etc.
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    "kubernetes.io/role/elb"                       = "1"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.eks.id
  count     = length(var.private_subnet_cidr)
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "eks-private-subnet-${count.index + 1}"
    #each subnet will be named eks-private-subnet-1, eks-private-subnet-2, etc.
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    "kubernetes.io/role/internal-elb"              = "1"
  }
}


resource "aws_internet_gateway" "eks-igw" {
    vpc_id = aws_vpc.eks.id

    tags = {
        Name = "${var.cluster_name}-igw"
        "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    }
}

resource "aws_eip" "eks-nat-eip" {
    vpc = true
    count = length(var.public_subnet_cidr)
}

resource "aws_nat_gateway" "eks-nat-gw" {
    allocation_id = aws_eip.eks-nat-eip[count.index].id
    count = length(var.public_subnet_cidr)
    subnet_id = aws_subnet.public-subnet[count.index].id
    tags = {
        Name = "${var.cluster_name}-nat-gw-${count.index + 1}"
        "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.eks.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.eks-igw.id
    }

    tags = {
        Name = "${var.cluster_name}-public"
    }
}

resource "aws_route_table_association" "public-subnet-association" {
    count = length(var.public_subnet_cidr)
    subnet_id = aws_subnet.public-subnet[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.eks.id
    count = length(var.public_subnet_cidr)
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.eks-nat-gw[count.index].id
    }
    tags = {
        Name = "${var.cluster_name}-private-${count.index + 1}"
    }
}


resource "aws_route_table_association" "private-subnet-association" {
    count = length(var.private_subnet_cidr)
    subnet_id = aws_subnet.private-subnet[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}
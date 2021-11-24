resource "aws_vpc" "poc-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "poc-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.AWS_REGION]
  }
}

# public subnet for webservers
resource "aws_subnet" "web-server-sub" {
  vpc_id                  = aws_vpc.poc-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = "true"
  tags = {
    Name = "web-server-sub"
  }
}

# private subnet for api-server
resource "aws_subnet" "api-server-sub" {
  vpc_id            = aws_vpc.poc-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "api-server-sub"
  }
}

# private subnet for rds database
resource "aws_subnet" "rds-db-sub1" {
  vpc_id            = aws_vpc.poc-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "rds-db-sub1"
  }
}

# private subnet for rds database
resource "aws_subnet" "rds-db-sub2" {
  vpc_id            = aws_vpc.poc-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[4]
  tags = {
    Name = "rds-db-sub2"
  }
}

# Internet Gateway and attached to "poc-vpc"
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.poc-vpc.id

  tags = {
    Name = "igw-poc-vpc"
  }
}

# Create custom route table and associate all public subnets
resource "aws_route_table" "rt-pub" {
  vpc_id = aws_vpc.poc-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "rt-pub"
  }
  depends_on = [
    aws_internet_gateway.gw
  ]
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-server-sub.id
  route_table_id = aws_route_table.rt-pub.id
}

# Create second custom route table and associate all private subnets

resource "aws_route_table" "rt-pvt" {
  vpc_id = aws_vpc.poc-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "rt-pvt"
  }
  depends_on = [
    aws_nat_gateway.nat-gw
  ]
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.api-server-sub.id
  route_table_id = aws_route_table.rt-pvt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.rds-db-sub1.id
  route_table_id = aws_route_table.rt-pvt.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.rds-db-sub2.id
  route_table_id = aws_route_table.rt-pvt.id
}


# Create NAT Gateway

# Create EIP and attached to network interface
resource "aws_eip" "nat-eip" {
  vpc = true
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.web-server-sub.id
  tags = {
    Name = "nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.gw,
    aws_eip.nat-eip
  ]
}

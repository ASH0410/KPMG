
# Create security group for "web-server"
resource "aws_security_group" "web-server-sg" {
  name        = "web-server-sg"
  description = "security group for web-server "
  vpc_id      = aws_vpc.poc-vpc.id
  ingress {
    description = "ssh from my-ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    # restrict to certain ip
    #cidr_blocks = ["ips"]
  }

  ingress {
    description = "HTTP from my-ip"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    # restrict to certain ips
    #cidr_blocks = ["ips"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    # restrict to certain ips
    #cidr_blocks = ["ips"]
  }

  tags = {
    Name = "web-server-sg"
  }

  depends_on = [
    aws_vpc.poc-vpc,
  ]
}


# Create security group for "api-server"
resource "aws_security_group" "api-server-sg" {
  name        = "api-server-sg"
  description = "security group for api-server "
  vpc_id      = aws_vpc.poc-vpc.id
  ingress {
    description = "ssh from web-server-subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.web-server-sub.cidr_block]

    # restrict to certain ip
    #cidr_blocks = ["ips"]
  }

  ingress {
    description = "HTTP from web-server-subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.web-server-sub.cidr_block]

    # restrict to certain ips
    #cidr_blocks = ["ips"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    # restrict to certain ips
    #cidr_blocks = ["ips"]
  }

  tags = {
    Name = "api-server-sg"
  }

  depends_on = [
    aws_vpc.poc-vpc,
  ]
}

# Create security group for "rds-db"
resource "aws_security_group" "rds-db-sg" {
  name        = "rds-db-sg"
  description = "security group for rds-db "
  vpc_id      = aws_vpc.poc-vpc.id
  ingress {
    description = "mysql traffic from api-server-subnet"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.api-server-sub.cidr_block]

    # restrict to certain ip
    #cidr_blocks = ["ips"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    # restrict to certain ips
    #cidr_blocks = ["ips"]
  }

  tags = {
    Name = "rds-db-sg"
  }

  depends_on = [
    aws_vpc.poc-vpc,
  ]
}
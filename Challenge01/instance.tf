
# Create Key-pair to SSH to servers
resource "aws_key_pair" "web-server-tf" {
  key_name   = "web-server-tf"
  public_key = file("web-server-tf.pub")
}

# Create "web-server" instance in the public subnet
resource "aws_instance" "web-server" {
  ami             = lookup(var.AMIS, var.AWS_REGION)
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.web-server-tf.id
  security_groups = [aws_security_group.web-server-sg.id]
  subnet_id       = aws_subnet.web-server-sub.id
  user_data       = file("install_apache.sh")
  tags = {
    Name = "web-server"
  }

  depends_on = [
    aws_key_pair.web-server-tf,
    aws_security_group.web-server-sg
  ]
}

output "WEB-Server-Private_IP" {
  value = aws_instance.web-server.private_ip
}
output "WEB-Server-Public_IP" {
  value = aws_instance.web-server.public_ip
}


# Create "api-server" instance in the private subnet
resource "aws_instance" "api-server" {
  ami             = lookup(var.AMIS, var.AWS_REGION)
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.web-server-tf.id
  security_groups = [aws_security_group.api-server-sg.id]
  subnet_id       = aws_subnet.api-server-sub.id
  user_data       = file("install_apache_mysql.sh")
  tags = {
    Name = "api-server"
  }

  depends_on = [
    aws_key_pair.web-server-tf,
    aws_security_group.api-server-sg,
    aws_nat_gateway.nat-gw
  ]
}

output "API-Server-Private_IP" {
  value = aws_instance.api-server.private_ip
}

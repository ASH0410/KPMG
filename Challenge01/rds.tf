resource "aws_db_subnet_group" "db-subnet-gp" {
  name       = "db-subnet-gp"
  subnet_ids = [aws_subnet.rds-db-sub1.id, aws_subnet.rds-db-sub2.id]

  tags = {
    Name = "db-subnet-gp"
  }
}

resource "aws_db_instance" "mysql-db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = "mydb"
  username               = var.DB_USERNAME
  password               = var.DB_PASSWORD
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  availability_zone      = data.aws_availability_zones.available.names[3]
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-gp.id
  vpc_security_group_ids = [aws_security_group.rds-db-sg.id]

  depends_on = [
    aws_security_group.rds-db-sg,
    aws_db_subnet_group.db-subnet-gp
  ]
}

output "MYSQL_Endpoint" {
  value = aws_db_instance.mysql-db.endpoint
}
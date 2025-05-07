resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_db_instance" "auth_db" {
  identifier         = "auth-db"
  allocated_storage  = 20
  engine             = "postgres"
  engine_version     = "15.3"
  instance_class     = "db.t3.micro"
  name               = "auth_db"
  username           = var.db_username
  password           = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot = true
  publicly_accessible = false
}

resource "aws_db_instance" "users_db" {
  identifier         = "users-db"
  allocated_storage  = 20
  engine             = "postgres"
  engine_version     = "15.3"
  instance_class     = "db.t3.micro"
  name               = "users_db"
  username           = var.db_username
  password           = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot = true
  publicly_accessible = false
}

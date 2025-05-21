resource "aws_db_instance" "auth_db" {
  identifier         = "${var.project_name}-auth-db"
  engine             = "postgres"
  engine_version     = "15"
  instance_class     = var.db_instance_class
  allocated_storage  = 20
  db_name            = "authdb"
  username           = var.db_username
  password           = var.db_password
  port               = 5432
  publicly_accessible = false
  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = var.db_subnet_group_name
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-auth-db"
  }
}

resource "aws_db_instance" "users_db" {
  identifier         = "${var.project_name}-users-db"
  engine             = "postgres"
  engine_version     = "15"
  instance_class     = var.db_instance_class
  allocated_storage  = 20
  db_name            = "userdb"
  username           = var.db_username
  password           = var.db_password
  port               = 5432
  publicly_accessible = false
  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = var.db_subnet_group_name
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-users-db"
  }
}

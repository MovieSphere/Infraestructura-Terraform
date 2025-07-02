locals {
  parameter_group_name = var.parameter_group_name != "" ? var.parameter_group_name : "${var.project_name}-pg"
}

resource "aws_db_parameter_group" "this" {
  name        = local.parameter_group_name
  family      = "postgres15"
  description = "Grupo de parámetros para ${var.project_name}"

  # Registro de todas las sentencias SQL
  parameter {
    name  = "log_statement"
    value = "all"
  }

  # Registro detallado de todas las consultas (duración mínima = 0 ms)
  parameter {
    name  = "log_min_duration_statement"
    value = "0"
  }

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }
  parameter {
    name  = "log_disconnections"
    value = "1"
  }
  parameter {
    name  = "log_lock_waits"
    value = "1"
  }
}

resource "aws_db_instance" "auth_db" {
  identifier                            = "${var.project_name}-auth-db"
  engine                                = "postgres"
  engine_version                        = "15"
  instance_class                        = var.db_instance_class
  allocated_storage                     = 20
  db_name                               = "authdb"
  username                              = var.db_username
  password                              = var.db_password
  port                                  = 5432
  publicly_accessible                   = false
  vpc_security_group_ids                = [var.rds_sg_id]
  db_subnet_group_name                  = var.db_subnet_group_name
  backup_retention_period               = var.backup_retention_period
  backup_window                         = var.backup_window
  parameter_group_name                  = aws_db_parameter_group.this.name

  storage_encrypted                     = true                         
  auto_minor_version_upgrade            = true                          
  deletion_protection                   = true                          
  skip_final_snapshot                   = false                         

  iam_database_authentication_enabled   = true                          

  performance_insights_enabled          = true                          
  performance_insights_retention_period = 7                             

  monitoring_interval                   = 60                            
  monitoring_role_arn                   = var.monitoring_role_arn      

  multi_az                              = true                          
  enabled_cloudwatch_logs_exports       = ["postgresql"]              

  copy_tags_to_snapshot                 = true

  tags = {
    Name = "${var.project_name}-auth-db"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_db_instance" "users_db" {
  identifier                            = "${var.project_name}-users-db"
  engine                                = "postgres"
  engine_version                        = "15"
  instance_class                        = var.db_instance_class
  allocated_storage                     = 20
  db_name                               = "userdb"
  username                              = var.db_username
  password                              = var.db_password
  port                                  = 5432
  publicly_accessible                   = false
  vpc_security_group_ids                = [var.rds_sg_id]
  db_subnet_group_name                  = var.db_subnet_group_name
  backup_retention_period               = var.backup_retention_period
  backup_window                         = var.backup_window
  parameter_group_name                  = aws_db_parameter_group.this.name

  storage_encrypted                     = true
  auto_minor_version_upgrade            = true
  deletion_protection                   = true
  skip_final_snapshot                   = false

  iam_database_authentication_enabled   = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval                   = 60
  monitoring_role_arn                   = var.monitoring_role_arn

  multi_az                              = true

  enabled_cloudwatch_logs_exports       = ["postgresql"]

  copy_tags_to_snapshot                 = true

  tags = {
    Name = "${var.project_name}-users-db"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_db_instance" "catalog_db" {
  identifier                            = "${var.project_name}-catalog-db"
  engine                                = "postgres"
  engine_version                        = "15"
  instance_class                        = var.db_instance_class
  allocated_storage                     = 20
  db_name                               = "catalogdb"
  username                              = var.db_username
  password                              = var.db_password
  port                                  = 5432
  publicly_accessible                   = false
  vpc_security_group_ids                = [var.rds_sg_id]
  db_subnet_group_name                  = var.db_subnet_group_name
  parameter_group_name                  = aws_db_parameter_group.this.name
  storage_encrypted                     = true
  auto_minor_version_upgrade            = true
  deletion_protection                   = true
  skip_final_snapshot                   = false

  iam_database_authentication_enabled   = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval                   = 60
  monitoring_role_arn                   = var.monitoring_role_arn

  multi_az                              = true
  enabled_cloudwatch_logs_exports       = ["postgresql"]

  copy_tags_to_snapshot                 = true

  tags = {
    Name = "${var.project_name}-catalog-db"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_db_instance" "rating_db" {
  identifier                            = "${var.project_name}-rating-db"
  engine                                = "postgres"
  engine_version                        = "15"
  instance_class                        = var.db_instance_class
  allocated_storage                     = 20
  db_name                               = "ratingdb"
  username                              = var.db_username
  password                              = var.db_password
  port                                  = 5432
  publicly_accessible                   = false
  vpc_security_group_ids                = [var.rds_sg_id]
  db_subnet_group_name                  = var.db_subnet_group_name
  parameter_group_name                  = aws_db_parameter_group.this.name
  storage_encrypted                     = true
  auto_minor_version_upgrade            = true
  deletion_protection                   = true
  skip_final_snapshot                   = false

  iam_database_authentication_enabled   = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval                   = 60
  monitoring_role_arn                   = var.monitoring_role_arn

  multi_az                              = true
  enabled_cloudwatch_logs_exports       = ["postgresql"]

  copy_tags_to_snapshot                 = true

  tags = {
    Name = "${var.project_name}-rating-db"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_db_instance" "recommendation_db" {
  identifier                            = "${var.project_name}-recommendation-db"
  engine                                = "postgres"
  engine_version                        = "15"
  instance_class                        = var.db_instance_class
  allocated_storage                     = 20
  db_name                               = "recommendationdb"
  username                              = var.db_username
  password                              = var.db_password
  port                                  = 5432
  publicly_accessible                   = false
  vpc_security_group_ids                = [var.rds_sg_id]
  db_subnet_group_name                  = var.db_subnet_group_name
  parameter_group_name                  = aws_db_parameter_group.this.name
  storage_encrypted                     = true
  auto_minor_version_upgrade            = true
  deletion_protection                   = true
  skip_final_snapshot                   = false

  iam_database_authentication_enabled   = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval                   = 60
  monitoring_role_arn                   = var.monitoring_role_arn

  multi_az                              = true
  enabled_cloudwatch_logs_exports       = ["postgresql"]

  copy_tags_to_snapshot                 = true

  tags = {
    Name = "${var.project_name}-recommendation-db"
  }

  lifecycle {
    prevent_destroy = true
  }
}


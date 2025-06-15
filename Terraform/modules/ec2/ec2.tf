# EC2 de los microservicios
resource "aws_instance" "ec2_ubuntu_docker" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.private_id
  vpc_security_group_ids      = [var.ec2_sg_id]
  key_name                    = var.key_name
  monitoring                  = true
  iam_instance_profile        = var.iam_instance_profile
  ebs_optimized               = true  

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  user_data = templatefile("${path.module}/scripts/ec2_ms_setup.sh.tpl", {
    MS_AUTH_DB_URL = local.ms_auth_db_url
    MS_USER_DB_URL = local.ms_user_db_url
    DB_USERNAME    = var.db_username
    DB_PASSWORD    = var.db_password
  })

  tags = {
    Name = "${var.project_name}-ec2-ubuntu-ms"
  }
}

locals {
  ms_auth_db_url = "jdbc:postgresql://${var.auth_db_host}:5432/authdb"
  ms_user_db_url = "jdbc:postgresql://${var.user_db_host}:5432/userdb"
}
# EC2 de los microservicios
resource "aws_instance" "ec2_ubuntu_docker" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.private_id
  vpc_security_group_ids      = [var.ec2_sg_id]
  key_name                    = var.key_name

  user_data = templatefile("${path.module}/scripts/ec2_ms_setup.sh.tpl", {
    # DB de los ms (Aumentaran con el tiempo)
    auth_db_host = var.auth_db_host
    user_db_host = var.user_db_host

    # Datos de la BD
    db_username  = var.db_username
    db_password  = var.db_password
  })

  tags = {
    Name = "${var.project_name}-ec2-ubuntu-ms"
  }
}

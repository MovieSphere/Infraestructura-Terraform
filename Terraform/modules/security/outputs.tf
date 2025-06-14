# Muestra el ID del Grupo de Seguridad de EC2
output "ec2_sg_id" {
  description = "ID del Grupo de Seguridad de EC2"
  value = aws_security_group.ec2_sg.id
}

# Muestra el ID del Grupo de Seguridad de RDS
output "rds_sg_id" {
  description = "ID del Grupo de Seguridad de RDS"
  value = aws_security_group.rds_sg.id
}

# Muestra el ID del Grupo de Seguridad de SSH
output "ssh_sg_id" {
  description = "ID del Grupo de Seguridad de SSH"
  value = aws_security_group.ssh_sg.id
}

# Muestra el ID del Grupo de Seguridad de el ALB
output "alb_sg_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb_sg.id
}

# Muestra el ID del Grupo de Seguridad de el APIGateway
output "apigw_sg_id" {
  description = "ID del Security Group del APIGateway"
  value = aws_security_group.apigw_sg.id
}
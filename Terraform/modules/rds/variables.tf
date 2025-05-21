variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}
variable "db_username" {
  description = "Nombre de usurio de la BD"
}
variable "db_password" {
  description = "Contraseña de la BD"
}
variable "db_instance_class" {
  description = "Clase de instancia de la RDS"
}
variable "rds_sg_id" {
  description = "Security Group ID del RDS"
}
variable "db_subnet_group_name" {
  description = "Nombre de Grupo de la Subnet"
}
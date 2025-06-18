variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "db_username" {
  description = "Nombre de usuario de la BD"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la BD"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Clase de instancia de la RDS"
  type        = string
}

variable "rds_sg_id" {
  description = "Security Group ID del RDS"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Nombre de Grupo de la Subnet"
  type        = string
}

variable "monitoring_role_arn" {
  description = "ARN del IAM Role para Enhanced Monitoring"
  type        = string
}

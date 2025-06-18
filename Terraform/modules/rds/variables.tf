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

variable "backup_retention_period" {
  description = "Días de retención de backups de RDS"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Ventana de tiempo para los backups"
  type        = string
  default     = "03:00-04:00"
}

variable "parameter_group_name" {
  description = "Nombre del grupo de parámetros de la base de datos"
  type        = string
  default     = ""
}
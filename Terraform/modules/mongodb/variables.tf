variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "master_username" {
  description = "Usuario administrador del cluster"
  type        = string
  default     = "docdbadmin"
}

variable "master_password" {
  description = "Contraseña del usuario administrador"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Tipo de instancia de DocumentDB"
  type        = string
  default     = "db.t3.medium"
}

variable "subnet_ids" {
  description = "Subredes para el cluster"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group para DocumentDB"
  type        = string
}

variable "instance_count" {
  description = "Número de instancias"
  type        = number
  default     = 1
}

variable "docdb_kms_key_id" {
  description = "ARN de la CMK para cifrar el clúster DocumentDB"
  type        = string
}

variable "backup_retention_period" {
  description = "Número de días para retención de backups de DocumentDB"
  type        = number
  default     = 7     # mínimo 1–7 días, ajusta según tu política interna
}


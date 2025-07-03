variable "project_name" {
  type        = string
  description = "Nombre del proyecto, se usará en los nombres de recursos"
}

variable "log_group_name" {
  type        = string
  description = "Nombre del CloudWatch Log Group al que enviarán los logs"
}

variable "alarm_email" {
  type        = string
  description = "Correo que recibirá las notificaciones de SNS"
}

variable "log_retention_in_days" {
  description = "Días de retención de logs (al menos 365 para CKV_AWS_338)"
  type        = number
  default     = 365
}

variable "log_kms_key_id" {
  description = "ARN de la clave KMS para cifrar el Log Group"
  type        = string
  default     = ""   # o hazla obligatoria
}

variable "sns_kms_key_id" {
  description = "ARN de la clave KMS para cifrar el SNS Topic"
  type        = string
  default     = ""  # o quítalo para hacerlo obligatorio
}


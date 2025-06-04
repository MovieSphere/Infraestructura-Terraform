variable "project_name" {
  type        = string
  description = "Nombre del proyecto, se usará en los nombres de recursos"
}

variable "region" {
  type        = string
  description = "Región AWS donde se crearán los recursos"
}

variable "log_group_name" {
  type        = string
  description = "Nombre del CloudWatch Log Group al que enviarán los logs"
}

variable "alarm_email" {
  type        = string
  description = "Correo que recibirá las notificaciones de SNS"
}

variable "ec2_instance_id" {
  type        = string
  description = "ID de la instancia EC2 a monitorear (CPU, Memoria, etc.)"
}

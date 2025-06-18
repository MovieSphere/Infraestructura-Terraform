variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "ec2_instance_id" {
  description = "ID de la instancia EC2 que se va a monitorear"
  type        = string
}

variable "alarm_actions" {
  description = "Lista de ARNs a los que se enviarán las alarmas (SNS, etc)"
  type        = list(string)
  default     = []
}
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs de subredes públicas para el ALB"
  type        = list(string)
}

variable "instance_ids" {
  description = "ID de la instancia EC2 que se registrará en el target group"
  type = list(string)
}

variable "alb_sg_id" {
  description = "ID del security group del ALB"
  type        = string
}

# Variables para configuración de HTTPS y certificados
variable "enable_https" {
  description = "Habilitar HTTPS en el ALB"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM para HTTPS"
  type        = string
  default     = ""
}

# Variables para logging
variable "enable_alb_access_logs" {
  description = "Habilitar logs de acceso del ALB"
  type        = bool
  default     = false
}

variable "alb_logs_bucket" {
  description = "Bucket S3 para logs del ALB"
  type        = string
  default     = ""
}

# Variables para WAF
variable "alb_waf_arn" {
  description = "ARN del WAF Web ACL para proteger el ALB"
  type        = string
  default     = ""
}

# Variable legacy para compatibilidad
variable "acm_cert_arn" {
  description = "Certificado ACM (legacy)"
  type        = string
  default     = ""
}
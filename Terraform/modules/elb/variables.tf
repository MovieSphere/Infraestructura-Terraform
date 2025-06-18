variable "project_name" {
  description = "Nombre del proyecto para etiquetas y recursos"
  type        = string
}

variable "alb_sg_id" {
  description = "ID del Security Group asociado al ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas donde se desplegará el ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID del VPC donde residen los recursos"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN del certificado SSL para HTTPS Listener"
  type        = string
}

variable "instance_ids" {
  description = "Lista de instancias EC2 que serán registradas en los target groups"
  type        = list(string)
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


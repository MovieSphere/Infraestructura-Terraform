variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "integration_uri" {
  description = "URL del backend al que redirige el API Gateway (En este caso DNS público del ELB)"
  type        = string
}

# Variables para logging
variable "enable_access_logs" {
  description = "Habilitar logs de acceso en API Gateway"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "Bucket S3 para logs de acceso de API Gateway"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "Prefijo para logs de acceso de API Gateway"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para encriptar CloudWatch Log Group"
  type        = string
  default     = ""
}

variable "enable_client_cert_auth" {
  description = "Habilitar autenticación con certificado de cliente"
  type        = bool
  default     = false
}

variable "client_cert_audience" {
  description = "Audiencia para el certificado de cliente JWT"
  type        = string
  default     = ""
}

variable "client_cert_issuer" {
  description = "Emisor para el certificado de cliente JWT"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate to use for a custom domain"
  type        = string
  default     = ""   
}

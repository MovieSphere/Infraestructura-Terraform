variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "bucket_arn" {
  description = "ARN del bucket S3 al que CloudFront debe acceder"
  type        = string
}

variable "bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
}

variable "bucket_domain" {
  description = "Dominio regional del bucket S3"
  type        = string
}

variable "cf_price_class" {
  description = "Clase de precio de CloudFront"
  type        = string
}

variable "log_bucket_name" {
  description = "Bucket donde se almacenan los logs de CloudFront"
  type        = string
}

variable "enable_access_logs" {
  description = "Habilitar logs de acceso en CloudFront"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "Bucket S3 para logs de acceso de CloudFront"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "Prefijo para logs de acceso de CloudFront"
  type        = string
  default     = ""
}

variable "failover_bucket_domain" {
  description = "Dominio del bucket S3 de failover para origin failover"
  type        = string
  default     = ""
}

# Variables para certificados SSL personalizados
variable "enable_custom_ssl" {
  description = "Habilitar certificado SSL personalizado en CloudFront"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM para CloudFront"
  type        = string
  default     = ""
}

variable "ssl_support_method" {
  description = "Método de soporte SSL para CloudFront"
  type        = string
  default     = "sni-only"
  validation {
    condition     = contains(["sni-only", "vip"], var.ssl_support_method)
    error_message = "ssl_support_method debe ser 'sni-only' o 'vip'."
  }
}

variable "minimum_protocol_version" {
  description = "Versión mínima del protocolo SSL/TLS"
  type        = string
  default     = "TLSv1.2_2021"
  validation {
    condition     = contains(["TLSv1", "TLSv1.1", "TLSv1.2_2019", "TLSv1.2_2021", "TLSv1.3"], var.minimum_protocol_version)
    error_message = "minimum_protocol_version debe ser una versión válida de TLS."
  }
}

variable "geo_restriction_locations" {
  description = "Lista de códigos de pais permitidos en CloudFront"
  type        = list(string)
  default     = ["US","CA","MX","BR","AR","CL","CO","PE","VE","EC","BO","PY","UY","GY","SR","GF","FK"]
}

# Agrega esta nueva variable al final del archivo
variable "waf_log_destination_arn" {
  description = "ARN del destino de logs para WAF (S3, CloudWatch o Kinesis)"
  type        = string
}

variable "web_acl_arn" {
  type        = string
  description = "ARN del WAFv2 Web ACL (para asociar con CloudFront)"
}

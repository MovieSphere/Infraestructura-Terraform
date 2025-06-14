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

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM para CloudFront"
  type        = string
}

variable "geo_locations" {
  description = "Lista de países permitidos para geo restriction"
  type        = list(string)
  default     = ["PE"]
}
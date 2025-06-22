variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "enable_waf_logging" {
  description = "Habilitar logging para WAF Web ACL"
  type        = bool
  default     = false
}

variable "waf_logs_bucket_arn" {
  description = "ARN del bucket S3 para logs de WAF"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment usado"
}
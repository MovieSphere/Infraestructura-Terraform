variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "ARN de la distribución de CloudFront"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para encriptar el bucket S3"
  type        = string
  default     = ""
}

variable "replication_destination_bucket" {
  description = "ARN del bucket de destino para replicación cross-region"
  type        = string
  default     = ""
} 
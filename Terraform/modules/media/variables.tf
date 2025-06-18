variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev/prod)"
  type        = string
}

variable "bucket_suffix" {
  description = "Sufijo único del bucket. Si no se especifica, se genera uno aleatorio."
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "ID o alias de la CMK para server-side encryption"
  type        = string
  default     = "alias/aws/s3"
}

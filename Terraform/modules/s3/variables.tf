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
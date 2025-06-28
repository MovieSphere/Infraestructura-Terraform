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

variable "bucket_name" {
  type        = string
  description = "Base del nombre de bucket (project_name-env-suffix)"
}

variable "kms_key_id" {
  type        = string
  description = "ID o alias de la CMK para server‑side encryption"
}
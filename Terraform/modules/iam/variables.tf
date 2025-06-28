variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (e.g., develop, production)"
  type        = string
}

variable "frontend_bucket_arn" {
  description = "ARN of the frontend bucket"
  type        = string
}

variable "frontend_logs_bucket_arn" {
  description = "ARN of the frontend logs bucket"
  type        = string
}

variable "frontend_replica_bucket_arn" {
  description = "ARN of the frontend replica bucket"
  type        = string
}
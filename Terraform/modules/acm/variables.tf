# Dominio para el certificado ACM
variable "domain_name" {
  description = "Dominio principal para el certificado ACM ej. moviesphere.com"
  type        = string
}

# Nombre del proyecto (usado en tags y nombres de recursos)
variable "project_name" {
  description = "Nombre del proyecto ej. moviesphere"
  type        = string
}

# Entorno (dev, staging, prod, etc.)
variable "environment" {
  description = "Nombre del entorno ej. dev, prod"
  type        = string
}

# ID de la zona hospedada en Route 53 para validar el certificado ACM
# variable "hosted_zone_id" {
#   description = "ID de la zona hospedada de Route 53 asociada al dominio"
#   type        = string
# }

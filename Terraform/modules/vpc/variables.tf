variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR del VPC"
  type        = string
}
variable "public_subnet_cidrs" {
  description = "CIDRs de subredes públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs de subredes privadas"
  type        = list(string)
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para subredes"
  type        = list(string)
}

variable "flow_logs_role_arn" {
  description = "ARN del rol IAM para VPC Flow Logs"
  type        = string
}
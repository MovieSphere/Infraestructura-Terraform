variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR del VPC"
  type        = string
}
variable "public_subnet_cidr" {
  description = "CIDRs de subred pública"
}
variable "private_subnet_cidr" {
  description = "CIDRs de subred privada"
}
variable "availability_zone" {
  description = "Zonas de disponibilidad"
}

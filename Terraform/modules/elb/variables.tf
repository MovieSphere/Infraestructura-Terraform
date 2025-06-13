variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs de subredes públicas para el ALB"
  type        = list(string)
}

variable "instance_ids" {
  description = "ID de la instancia EC2 que se registrará en el target group"
  type = list(string)
}

variable "alb_sg_id" {
  description = "ID del security group del ALB"
  type        = string
}
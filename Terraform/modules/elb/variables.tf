variable "project_name" {
  description = "Nombre del proyecto para etiquetas y recursos"
  type        = string
}

variable "alb_sg_id" {
  description = "ID del Security Group asociado al ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas donde se desplegará el ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID del VPC donde residen los recursos"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN del certificado SSL para HTTPS Listener"
  type        = string
}

variable "instance_ids" {
  description = "Lista de instancias EC2 que serán registradas en los target groups"
  type        = list(string)
}

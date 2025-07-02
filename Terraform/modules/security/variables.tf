variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}
variable "vpc_id" {
  description = "Id del vpc"
}
variable "user_ip_cidr" {
  description = "Ip de la persona que quiera usar la conexión SSH"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = ""
}

variable "ssh_cidr" {
  description = "Rango CIDR desde el que permitimos SSH"
  type        = string
}

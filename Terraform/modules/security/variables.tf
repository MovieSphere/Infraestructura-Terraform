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
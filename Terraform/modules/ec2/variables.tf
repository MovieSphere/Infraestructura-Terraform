variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}
variable "ami_id" {
  description = "AMI del EC2"
}
variable "instance_type" {
  description = "Tipo de instancia"
}
variable "private_id" {
  description = "Id de la subnet privada"
}
variable "ec2_sg_id" {
  description = "ID del security group para la EC2"
}

variable "key_name" {
  description = "Key name del EC2"
}

variable "auth_db_host" {
  description = "Url del DB de Auth"
}
variable "user_db_host" {
  description = "Url del DB de User"
}
variable "db_username" {
  description = "Username para ingresar a la BD"
}
variable "db_password" {
  description = "Password para ingresar a la BD"
}
variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "MovieSphere"
}

variable "vpc_cidr" {
  description = "CIDR del VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDRs de subred pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDRs de subred privada"
  type        = string
  default     = "10.0.3.0/24"
}

variable "user_ip_cidr" {
  description = "IP personal para acceso SSH (formato: x.x.x.x/32)"
  type        = string
}

variable "availability_zone" {
  description = "Zonas de disponibilidad"
  type        = string
  default     = "us-east-1a"
}

variable "ami_id" {
  description = "AMI ID para EC2"
  type        = string
  default     = "ami-0e449927258d45bc4"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "Tipo de instancia RDS"
  default = "db.t3.micro"
}

variable "key_name" {
  description = "Nombre del par de claves EC2"
  type        = string
  default     = "pair_key_moviesphere"
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type      = string
  sensitive = true
}
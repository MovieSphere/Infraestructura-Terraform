variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "MovieSphere"
}

variable "environment" {
  description = "Entorno (dev/prod)"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Nombre base del bucket S3"
  type        = string
  default     = "moviesphere-frontend"
}

variable "bucket_suffix" {
  description = "Sufijo único para el bucket (dejar vacío para autogenerar)"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR del VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs de subred pública"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs de subred privada"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Zonas de disponibilidad"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
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

variable "key_name" {
  description = "Nombre del par de claves EC2"
  type        = string
  default     = "pair_key_moviesphere"
}

variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "cf_price_class" {
  description = "Clase de precio CloudFront"
  type        = string
  default     = "PriceClass_100"
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type      = string
  sensitive = true
}

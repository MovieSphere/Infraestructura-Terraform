variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "moviesphere"
}

variable "vpc_cidr" {
  description = "CIDR del VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs de subredes públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs de subredes privadas"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "user_ip_cidr" {
  description = "IP personal para acceso SSH"
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidad"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ami_id" {
  description = "AMI ID para EC2"
  type        = string
  default     = "ami-084568db4383264d4"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "Tipo de instancia RDS"
  default     = "db.t3.micro"
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

variable "alarm_email" {
  type = string
  description = "Correo al que se enviarán las alertas"
  default = "jromerou2@upao.edu.pe"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "bucket_suffix" {
  type    = string
  default = ""
}

variable "cf_price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "kms_key_id" {
  description = "KMS Key ID or ARN to use for S3 bucket and other encryptions"
  type        = string
}

variable "flow_logs_role_arn" {
  description = "ARN del IAM Role para los VPC Flow Logs"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM para usar en API Gateway u otros servicios"
  type        = string
}

variable "monitoring_role_arn" {
  description = "ARN del rol de IAM usado para monitoreo de RDS (o CloudWatch)"
  type        = string
}

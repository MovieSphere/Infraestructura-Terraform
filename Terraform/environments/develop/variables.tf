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
  type        = string
  description = "Correo al que se enviarán las alertas"
  default     = "jromerou2@upao.edu.pe"
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
  default     = "PriceClass_100"
}

variable "flow_logs_role_arn" {
  description = "ARN del rol para VPC Flow Logs"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN del certificado TLS para el ALB (valor temporal)"
  type        = string
  default     = "arn:aws:acm:us-east-1:000000000000:certificate/mock-certificate"
}

variable "alb_sg_id" {
  description = "ID del Security Group usado por el ALB"
  type        = string
  default     = "sg-0123456789abcdef0"
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas donde se ubicará el ALB"
  type        = list(string)
  default     = ["subnet-0abc1111", "subnet-0abc2222"]
}

variable "vpc_id" {
  description = "ID del VPC al que pertenece el ALB y otros recursos"
  type        = string
  default     = "vpc-0123456789abcdef0"
}

variable "instance_ids" {
  description = "Lista de instancias EC2 que se conectarán al ALB"
  type        = list(string)
  default     = ["i-0123456789abcde01", "i-0123456789abcde02"]
}

variable "monitoring_role_arn" {
  description = "ARN del rol de IAM usado para monitoreo de RDS (o CloudWatch)"
  type        = string
}

variable "opensearch_engine_version" {
  description = "Versión de OpenSearch"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "opensearch_instance_type" {
  description = "Tipo de instancia para nodos de OpenSearch"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_instance_count" {
  description = "Número de instancias en el clúster de OpenSearch"
  type        = number
  default     = 1
}

variable "opensearch_access_policies" {
  description = "IAM policy JSON para OpenSearch"
  type        = string
}

variable "domain_name"{
  description = "Nombre del dominio"
  default = ""
}

variable "zone_id" {
  description = "Zona del dominio"
  default = ""
}

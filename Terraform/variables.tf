variable "ami_id" {
  description = "AMI ID para la instancia EC2"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS (cambia esto por una AMI válida)
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre del par de claves EC2"
  type        = string
  default     = "pair_kay"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "my-webapp"
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}
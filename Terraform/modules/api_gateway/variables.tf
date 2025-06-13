variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "integration_uri" {
  description = "URL del backend al que redirige el API Gateway (En este caso DNS público del ELB)"
  type        = string
}
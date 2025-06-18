variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "node_type" {
  description = "Tipo de nodo para Redis"
  type        = string
  default     = "db.t4g.small"
}

variable "subnet_ids" {
  description = "Lista de subredes privadas donde desplegar Redis"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID del Security Group asignado a Redis"
  type        = string
}

variable "acl_name" {
  description = "Nombre del ACL de MemoryDB"
  type        = string
}

# Configuración básica del dominio OpenSearch
variable "region" {
  description = "AWS region for the OpenSearch domain"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
  default     = "moviesphere"
}

variable "engine_version" {
  description = "OpenSearch engine version"
  type        = string
  default     = "OpenSearch_2.11"  # Compatibilidad con TLS 1.2+ [[4]]
}

# Configuración de clúster para alta disponibilidad (CKV_AWS_318)
variable "instance_type" {
  description = "Instance type for OpenSearch nodes"
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of instances in the OpenSearch cluster (min 3 for HA)"
  type        = number
  default     = 3  # Requerido para alta disponibilidad [[9]]
}

variable "dedicated_master_enabled" {
  description = "Enable dedicated master nodes for HA"
  type        = bool
  default     = true  # Nodos maestros dedicados [[9]]
}

variable "zone_awareness_enabled" {
  description = "Enable zone awareness for multi-AZ distribution"
  type        = bool
  default     = true  # Distribución en múltiples zonas de disponibilidad [[9]]
}

# Almacenamiento EBS
variable "ebs_enabled" {
  description = "Enable EBS volumes"
  type        = bool
  default     = true
}

variable "ebs_volume_size" {
  description = "Size of EBS volumes in GB"
  type        = number
  default     = 10
}

variable "ebs_volume_type" {
  description = "Type of EBS volume"
  type        = string
  default     = "gp2"
}

# Seguridad y cifrado
variable "kms_key_id" {
  description = "ARN of the KMS key for encryption at rest"
  type        = string
}

variable "tls_security_policy" {
  description = "TLS security policy for domain endpoint, e.g., 'Policy-Min-TLS-1-2-2019-07'"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"  # TLS 1.2 mínimo 
}

# Networking y Security Group personalizado (CKV_AWS_248)
variable "vpc_id" {
  description = "ID of the VPC to deploy OpenSearch (required to avoid default SG)"
  type        = string  # Requerido para crear un Security Group personalizado [[9]]
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access OpenSearch"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Ajustar según el entorno 
}

variable "vpc_subnet_ids" {
  description = "Subnets privadas para OpenSearch en VPC"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security Groups para OpenSearch en VPC"
  type        = list(string)
  default     = []  # Reemplazado por un SG personalizado [[9]]
}

# Logs y políticas de acceso
variable "audit_log_group_arn" {
  description = "ARN de CloudWatch Log Group para audit logs de OpenSearch"
  type        = string
}

variable "index_slow_log_group_arn" {
  description = "ARN de Log Group para index slow logs"
  type        = string
}

variable "search_slow_log_group_arn" {
  description = "ARN de Log Group para search slow logs"
  type        = string
}

variable "opensearch_access_policies" {
  description = "Políticas de acceso para OpenSearch"
  type        = string
}

# Metadatos
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the OpenSearch domain"
  type        = map(string)
  default     = {}
}

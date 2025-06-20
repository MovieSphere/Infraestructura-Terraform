variable "region" {
  description = "AWS region for the OpenSearch domain"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
}

variable "engine_version" {
  description = "OpenSearch engine version"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "instance_type" {
  description = "Instance type for OpenSearch nodes"
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of instances in the OpenSearch cluster"
  type        = number
  default     = 1
}

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

variable "kms_key_id" {
  description = "ARN of the KMS key for encryption at rest"
  type        = string
}

variable "tls_security_policy" {
  description = "TLS security policy for domain endpoint, e.g., 'Policy-Min-TLS-1-2-2019-07'"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "tags" {
  description = "Tags to apply to the OpenSearch domain"
  type        = map(string)
  default     = {}
}

variable "opensearch_access_policies" {
  description = "Políticas de acceso para OpenSearch"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "Subnets privadas para OpenSearch en VPC"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security Groups para OpenSearch en VPC"
  type        = list(string)
}

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


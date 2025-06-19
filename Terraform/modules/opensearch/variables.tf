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

variable "access_policies" {
  description = "JSON-formatted IAM policy document for OpenSearch access"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the OpenSearch domain"
  type        = map(string)
  default     = {}
}


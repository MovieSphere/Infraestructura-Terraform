resource "aws_opensearch_domain" "moviesphere" {
  domain_name           = "moviesphere"
  engine_version        = "OpenSearch_2.11"
  cluster_config {
    instance_type = "t3.small.search"
    instance_count = 1
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }
  access_policies = var.opensearch_access_policies

  tags = {
    Name        = "${var.project_name}-os-domain"
    Environment = var.environment
  }
}

# CKV_AWS_137 & CKV_AWS_248: desplegar en VPC y no usar SG por defecto
vpc_options {
  subnet_ids         = var.vpc_subnet_ids
  security_group_ids = var.security_group_ids
}

# CKV_AWS_317 & CKV_AWS_84: habilitar audit + slow logs
log_publishing_options {
  log_type             = "AUDIT_LOGS"
  enabled              = true
  cloudwatch_log_group = var.audit_log_group_arn
}

log_publishing_options {
  log_type             = "INDEX_SLOW_LOGS"
  enabled              = true
  cloudwatch_log_group = var.index_slow_log_group_arn
}

log_publishing_options {
  log_type             = "SEARCH_SLOW_LOGS"
  enabled              = true
  cloudwatch_log_group = var.search_slow_log_group_arn
}

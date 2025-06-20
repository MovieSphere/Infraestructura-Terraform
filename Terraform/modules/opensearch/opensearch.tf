resource "aws_kms_key" "opensearch_kms" {
  description             = "KMS key for OpenSearch encryption"
  deletion_window_in_days = 7
}

resource "aws_opensearch_domain" "moviesphere" {
  domain_name           = "moviesphere"
  engine_version        = "OpenSearch_2.11"  # Ensure compatibility with TLS 1.2+ policies [[2]]

  cluster_config {
    instance_type   = "t3.small.search"
    instance_count  = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }

  vpc_options {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = var.security_group_ids
  }

  log_publishing_options {
    log_type                 = "AUDIT_LOGS"
    enabled                  = true
    cloudwatch_log_group_arn = var.audit_log_group_arn
  }

  log_publishing_options {
    log_type                 = "INDEX_SLOW_LOGS"
    enabled                  = true
    cloudwatch_log_group_arn = var.index_slow_log_group_arn
  }

  log_publishing_options {
    log_type                 = "SEARCH_SLOW_LOGS"
    enabled                  = true
    cloudwatch_log_group_arn = var.search_slow_log_group_arn
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.opensearch_kms.arn  # Reference to the KMS key
  }

  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"  # Minimum TLS 1.2 for secure connections [[3]]
  }

  access_policies = var.opensearch_access_policies

  tags = {
    Name        = "${var.project_name}-os-domain"
    Environment = var.environment
  }
}

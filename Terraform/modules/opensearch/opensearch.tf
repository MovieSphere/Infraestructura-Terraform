# Clave KMS para cifrado en reposo (CKV_AWS_247 y CKV_AWS_5)
resource "aws_kms_key" "opensearch_kms" {
  description             = "KMS key for OpenSearch encryption"
  deletion_window_in_days = 7
}

# Security Group personalizado para OpenSearch (CKV_AWS_248)
resource "aws_security_group" "opensearch_sg" {
  name        = "${var.project_name}-opensearch-sg"
  description = "Reglas de seguridad para OpenSearch"
  vpc_id      = var.vpc_id  # Requerido para evitar usar el Security Group por defecto [[4]]

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks  # Ejemplo: ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-opensearch-sg"
  }
}

# Dominio de OpenSearch con configuración segura
resource "aws_opensearch_domain" "moviesphere" {
  domain_name           = "moviesphere"
  engine_version        = "OpenSearch_2.11"  # Compatibilidad con TLS 1.2+ [[2]]

  # Configuración de clúster para alta disponibilidad (CKV_AWS_318)
  cluster_config {
    instance_type           = "t3.small.search"
    instance_count          = 3  # Mínimo 3 nodos para HA [[8]]
    dedicated_master_enabled = true  # Nodos maestros dedicados
    zone_awareness_enabled   = true  # Distribución en múltiples zonas de disponibilidad [[8]]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }

  vpc_options {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [aws_security_group.opensearch_sg.id]  # Usar SG personalizado (CKV_AWS_248) [[4]]
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
    kms_key_id = aws_kms_key.opensearch_kms.arn  # Cifrado con CMK (CKV_AWS_247 y CKV_AWS_5)
  }

  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"  # TLS 1.2 mínimo [[3]]
  }

  access_policies = var.opensearch_access_policies

  tags = {
    Name        = "${var.project_name}-os-domain"
    Environment = var.environment
  }
}

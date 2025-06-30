# Clave KMS para cifrado en reposo (CKV_AWS_247 y CKV_AWS_5)
resource "aws_kms_key" "opensearch_kms" {
  description             = "KMS key for OpenSearch encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true  # Habilitar rotación de clave
}

# Security Group personalizado para OpenSearch (CKV_AWS_248)
resource "aws_security_group" "opensearch_sg" {
  name        = "${var.project_name}-opensearch-sg"
  description = "Reglas de seguridad para OpenSearch"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks  # Ejemplo: ["10.0.0.0/16"]
    description = "Allow HTTPS traffic from internal subnets"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS egress to internal networks"
  }

  tags = {
    Name = "${var.project_name}-opensearch-sg"
  }
}

resource "aws_opensearch_domain" "moviesphere" {
  domain_name           = "moviesphere"
  engine_version        = "OpenSearch_2.11"

  # Configuración de clúster para alta disponibilidad (CKV_AWS_318)
  cluster_config {
    instance_type            = "t3.small.search"
    instance_count           = 4  # Mínimo 3 nodos para HA [[9]]
    dedicated_master_enabled = true  # Nodos maestros dedicados
    zone_awareness_enabled   = true  # Distribución en múltiples zonas de disponibilidad [[8]]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }

  vpc_options {
    subnet_ids         = ["subnet-0d8c3b0a9237dbb93", "subnet-0a6e3d6a9ddf451e7"]
    security_group_ids = ["sg-071708ddaa092e351"]
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

  node_to_node_encryption {
    enabled = true  # Enable end-to-end encryption between nodes [[1]][[9]]
  }

    advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = false

    master_user_options {
      master_user_arn = var.opensearch_master_user_arn
    }
  }

  access_policies = var.opensearch_access_policies

  tags = {
    Name        = "${var.project_name}-os-domain"
    Environment = var.environment
  }
}

# Definición de la política de acceso
data "aws_iam_policy_document" "opensearch_access_policy" {
  statement {
    actions   = ["es:*", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "arn:aws:es:us-east-1:512248046326:domain/${var.domain_name}/*",
      "arn:aws:logs:us-east-1:512248046326:log-group:/os/moviesphere/search-slow-logs:*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# Asignación de la política al dominio
resource "aws_opensearch_domain_policy" "moviesphere" {
  domain_name     = aws_opensearch_domain.moviesphere.domain_name
  access_policies = data.aws_iam_policy_document.opensearch_access_policy.json
}

resource "aws_cloudwatch_log_group" "search_slow_logs" {
  name = "/os/moviesphere/search-slow-logs"
}

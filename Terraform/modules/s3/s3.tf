resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "frontend" {
  bucket = "${lower(var.project_name)}-${var.environment}-${coalesce(var.bucket_suffix, random_id.bucket_suffix.hex)}"

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [bucket]
  }

  # CKV_AWS_20 & CKV_AWS_57: Evita ACLs públicas
  acl = "private"

  # CKV_AWS_21: Habilita versionado
  versioning {
    enabled = true
  }

  # CKV_AWS_18: Habilita access logging
  logging {
    target_bucket = aws_s3_bucket.frontend_logs.id
    target_prefix = "access-logs/"
  }

  # CKV_AWS_144: Configura replicación cross‑region
  replication_configuration {
    role = aws_iam_role.replication_role.arn

    rule {
      id     = "cross-region"
      status = "Enabled"
      prefix = ""

      destination {
        bucket        = aws_s3_bucket.frontend_replica.arn
        storage_class = "STANDARD"
      }
    }
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CKV_AWS_145: Encriptación por defecto con KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

# CKV2_AWS_62: Notificaciones de eventos habilitadas
resource "aws_s3_bucket_notification" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  topic {
    topic_arn     = aws_sns_topic.object_created.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".jpg"
  }
}

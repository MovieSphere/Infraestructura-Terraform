resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_kms_key" "sns" {
  description             = "KMS key for SNS topic encryption"
  deletion_window_in_days = 10
}

resource "aws_sns_topic" "object_created" {
  name = "${var.project_name}-object-created-topic"
  # Enables server-side encryption at rest
  kms_master_key_id = aws_kms_key.sns.arn
  tags = {
    Environment = var.environment
    Service     = "s3-object-events"
  }
}

resource "aws_sns_topic_policy" "allow_s3_publish" {
  arn    = aws_sns_topic.object_created.arn
  policy = data.aws_iam_policy_document.s3_publish_to_sns.json
}

data "aws_iam_policy_document" "s3_publish_to_sns" {
  statement {
    sid    = "AllowS3ToPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["SNS:Publish"]

    resources = [aws_sns_topic.object_created.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [
        aws_s3_bucket.frontend.arn,
        aws_s3_bucket.frontend_logs.arn,
        aws_s3_bucket.frontend_replica.arn
      ]
    }
  }
}

resource "aws_s3_bucket" "frontend" {
  bucket = "${lower(var.project_name)}-${var.environment}-${coalesce(var.bucket_suffix, random_id.bucket_suffix.hex)}"

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes   = [bucket]
    
  }
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket" "frontend_logs" {
  bucket = "${var.project_name}-frontend-logs-${var.environment}"

  tags = {
    Name        = "${var.project_name}-frontend-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend_logs" {
  bucket = aws_s3_bucket.frontend_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# Permitir escritura de logs por parte del servicio de logging de S3
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "frontend_logs_write" {
  bucket = aws_s3_bucket.frontend_logs.id
  
policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSLogDeliveryWrite"
        Effect    = "Allow"
        Principal = { Service = "logging.s3.amazonaws.com" }
        Action    = ["s3:PutObject", "s3:GetBucketAcl"]
        Resource  = [aws_s3_bucket.frontend_logs.arn, "${aws_s3_bucket.frontend_logs.arn}/*"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "frontend_replica" {
  bucket = "${var.project_name}-frontend-replica-${var.environment}"
  tags = {
    Name        = "${var.project_name}-frontend-replica"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend_replica" {
  bucket = aws_s3_bucket.frontend_replica.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "frontend_logs" {
  bucket = aws_s3_bucket.frontend_logs.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_versioning" "frontend_replica" {
  bucket = aws_s3_bucket.frontend_replica.id
  versioning_configuration { status = "Enabled" }
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

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_kms_key" "logs"    { description = "KMS for frontend_logs" }
resource "aws_kms_key" "replica" { description = "KMS for frontend_replica" }

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_logs" {
  bucket = aws_s3_bucket.frontend_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.logs.arn
    }
    bucket_key_enabled = true   # cheaper KMS calls
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_replica" {
  bucket = aws_s3_bucket.frontend_replica.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.replica.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_replication_configuration" "logs_to_replica" {
  bucket = aws_s3_bucket.frontend_logs.id
  role   = aws_iam_role.s3_replication.arn

  rule {
    id     = "logs-replication"
    status = "Enabled"

    # Filtro para replicar to-do
    filter {}

    # Criterios de selección de objetos (requerido para SSE-KMS)
    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"  # Solo replica objetos cifrados con KMS
      }
    }

    delete_marker_replication {
      status = "Disabled"
    }

    destination {
      bucket        = aws_s3_bucket.frontend_replica.arn
      storage_class = "STANDARD"

      # Configuración de cifrado en destino
      encryption_configuration {
        replica_kms_key_id = var.kms_key_id  # KMS Key ARN
      }
      replication_time {
        status = "Enabled"
        time {
          minutes = 15
        }
      }
    }
  }
}


resource "aws_s3_bucket_replication_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  role   = aws_iam_role.s3_replication.arn

  rule {
    id     = "cross-region"
    status = "Enabled"

     filter {
      prefix = ""
    }

    delete_marker_replication {
      status = "Disabled"
    }

    destination {
      bucket        = aws_s3_bucket.frontend_replica.arn
      storage_class = "STANDARD"
    }
  }
}


resource "aws_s3_bucket_notification" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  topic {
    topic_arn     = aws_sns_topic.object_created.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".jpg"
  }
}

resource "aws_s3_bucket_notification" "frontend_logs" {
  bucket = aws_s3_bucket.frontend_logs.id

  topic {
    topic_arn = aws_sns_topic.object_created.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_notification" "frontend_replica" {
  bucket = aws_s3_bucket.frontend_replica.id

  topic {
    topic_arn = aws_sns_topic.object_created.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_iam_role" "replication_role" {
  name = "${var.project_name}-replication-role"

  assume_role_policy = data.aws_iam_policy_document.replication_policy.json
}

resource "aws_iam_role_policy" "s3_replication" {
  name   = "${var.project_name}-s3-replication-policy-${var.environment}"
  role   = aws_iam_role.s3_replication.id
  policy = data.aws_iam_policy_document.s3_replication.json
}

resource "aws_iam_role" "s3_replication" {
  name = "${var.project_name}-replication-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "s3_replication" {
  statement {
    sid       = "SourceAccess"
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.frontend.arn,
      "${aws_s3_bucket.frontend.arn}/*",
      aws_s3_bucket.frontend_logs.arn,
      "${aws_s3_bucket.frontend_logs.arn}/*"
    ]
  }
  statement {
    sid     = "DestinationWrite"
    effect  = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]
    resources = [
      aws_s3_bucket.frontend_replica.arn,
      "${aws_s3_bucket.frontend_replica.arn}/*"
    ]
  }
  statement {
    sid     = "KMSAccess"
    effect  = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.kms_key_id]
  }
}

data "aws_iam_policy_document" "replication_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

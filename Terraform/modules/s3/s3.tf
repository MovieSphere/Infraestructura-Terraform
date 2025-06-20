resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_sns_topic" "object_created" {
  name = "${var.project_name}-object-created-topic"
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
      values   = [aws_s3_bucket.frontend.arn]
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
    ignore_changes = [bucket]
  }

  logging {
    target_bucket = aws_s3_bucket.frontend_logs.id
    target_prefix = "access-logs/"
  }

  replication_configuration {
    role = aws_iam_role.replication_role.arn

    rules {
      id     = "cross-region"
      status = "Enabled"

      filter {
        prefix = ""
      }

      destination {
        bucket        = aws_s3_bucket.frontend_replica.arn
        storage_class = "STANDARD"
      }
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "frontend_versioning" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "frontend_logs" {
  bucket = "${var.project_name}-frontend-logs-${var.environment}"
}

resource "aws_s3_bucket_ownership_controls" "frontend_logs" {
  bucket = aws_s3_bucket.frontend_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_acl" "frontend_logs_acl" {
  bucket = aws_s3_bucket.frontend_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "frontend_replica" {
  bucket = "${var.project_name}-frontend-replica-${var.environment}"
}

resource "aws_s3_bucket_ownership_controls" "frontend_replica" {
  bucket = aws_s3_bucket.frontend_replica.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "frontend_replica_versioning" {
  bucket = aws_s3_bucket.frontend_replica.id

  versioning_configuration {
    status = "Enabled"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
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

resource "aws_iam_role" "replication_role" {
  name = "${var.project_name}-replication-role"

  assume_role_policy = data.aws_iam_policy_document.replication_policy.json
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

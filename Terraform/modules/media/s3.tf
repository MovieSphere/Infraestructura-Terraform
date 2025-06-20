resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  suffix = var.bucket_suffix != "" ? var.bucket_suffix : random_id.bucket_suffix.hex
}

resource "aws_s3_bucket" "media" {
  bucket = "${lower(var.project_name)}-${var.environment}-media-${local.suffix}"

  tags = {
    Name        = "${var.project_name}-media"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [bucket]
  }
}

resource "aws_s3_bucket_ownership_controls" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "media_versioning" {
  bucket = aws_s3_bucket.media.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "media_logs" {
  bucket = "${lower(var.project_name)}-${var.environment}-media-logs-${local.suffix}"

  tags = {
    Name        = "${var.project_name}-media-logs"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [bucket]
  }
}

resource "aws_s3_bucket_ownership_controls" "media_logs" {
  bucket = aws_s3_bucket.media_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_acl" "media_logs_acl" {
  bucket = aws_s3_bucket.media_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "media" {
  bucket        = aws_s3_bucket.media.id
  target_bucket = aws_s3_bucket.media_logs.id
  target_prefix = "access-logs/"
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket                  = aws_s3_bucket.media.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "media_logs" {
  bucket                  = aws_s3_bucket.media_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media_logs" {
  bucket = aws_s3_bucket.media_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_versioning" "media_logs_versioning" {
  bucket = aws_s3_bucket.media_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

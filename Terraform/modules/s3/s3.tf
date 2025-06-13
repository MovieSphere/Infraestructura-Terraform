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
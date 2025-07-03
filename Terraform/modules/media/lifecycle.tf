# Lifecycle for the 'media' bucket
resource "aws_s3_bucket_lifecycle_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    id     = "media-expire"
    status = "Enabled"

    # Expire objects older than 365 days
    expiration {
      days = 365
    }

    filter {}

    # Abort incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Lifecycle for the 'media_logs' bucket
resource "aws_s3_bucket_lifecycle_configuration" "media_logs" {
  bucket = aws_s3_bucket.media_logs.id

  rule {
    id     = "media-logs-expire"
    status = "Enabled"

    # Transition to Standard-IA after 60 days
    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }

    filter {
      prefix = "logs/"
    }

    # Delete after 30 days
    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

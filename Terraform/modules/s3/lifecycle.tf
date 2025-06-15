# File: modules/s3/lifecycle.tf

resource "aws_s3_bucket_lifecycle_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    id      = "expire-temp"
    status  = "Enabled"
    prefix  = "tmp/"

    expiration {
      days = 7
    }

    # ✎ CKV_AWS_300: abort multipart uploads tras 7 días
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "frontend_logs" {
  bucket = aws_s3_bucket.frontend_logs.id

  rule {
    id      = "expire-logs"
    status  = "Enabled"
    prefix  = ""

    expiration {
      days = 30
    }

    # ✎ CKV_AWS_300 para bucket de logs
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "frontend_replica" {
  bucket = aws_s3_bucket.frontend_replica.id

  rule {
    id      = "expire-replica"
    status  = "Enabled"
    prefix  = ""

    expiration {
      days = 30
    }

    # ✎ CKV_AWS_300 para bucket de réplica
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# File: modules/s3/versioning.tf

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "frontend_logs" {
  bucket = aws_s3_bucket.frontend_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "frontend_replica" {
  bucket = aws_s3_bucket.frontend_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

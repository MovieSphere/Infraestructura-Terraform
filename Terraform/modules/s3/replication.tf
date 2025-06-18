# File: modules/s3/replication.tf

# … (tus recursos aws_s3_bucket frontend_logs y frontend_replica) …

# ——————————————
# Public Access Block para frontend_logs
resource "aws_s3_bucket_public_access_block" "frontend_logs_block" {
  bucket                  = aws_s3_bucket.frontend_logs.id
  block_public_acls       = true    # CKV2_AWS_6
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Public Access Block para frontend_replica
resource "aws_s3_bucket_public_access_block" "frontend_replica_block" {
  bucket                  = aws_s3_bucket.frontend_replica.id
  block_public_acls       = true    # CKV2_AWS_6
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ——————————————
# Access Logging de frontend_logs (logs de sí mismo)
resource "aws_s3_bucket_logging" "frontend_logs_logging" {
  bucket        = aws_s3_bucket.frontend_logs.id
  target_bucket = aws_s3_bucket.frontend_logs.id  # almacena en sí mismo
  target_prefix = "self-logs/"                    # prefijo para distinguir
}

# Access Logging de frontend_replica
resource "aws_s3_bucket_logging" "frontend_replica_logging" {
  bucket        = aws_s3_bucket.frontend_replica.id
  target_bucket = aws_s3_bucket.frontend_logs.id  # envía los logs aquí
  target_prefix = "replica-logs/"
}

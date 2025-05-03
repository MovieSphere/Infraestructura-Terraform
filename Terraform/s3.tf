resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name

  # Habilita hosting estático: index.html y error.html
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "moviesphere-frontend"
  }
}

# Opcional: bloqueo de acceso público (recomendado)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

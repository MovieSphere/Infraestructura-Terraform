resource "aws_s3_bucket_lifecycle_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    id     = "expire-temp"
    status = "Enabled"

    filter {
      prefix = "tmp/"
    }

    expiration {
      days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "frontend_logs" {
  bucket = aws_s3_bucket.frontend_logs.id   # ID del bucket de logs

  rule {
    id     = "expire-logs"
    status = "Enabled"

    # Filtro opcional: sustituye "" por "logs/" si usas un prefijo
    filter { prefix = "" }

    # ❗ Abortar multipart uploads incompletos a los 7 días
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    # Borrar objetos de log tras 30 días
    expiration { days = 30 }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "frontend_replica" {
  bucket = aws_s3_bucket.frontend_replica.id   # ID del bucket réplica

  rule {
    id     = "expire-replica"
    status = "Enabled"

    # Sin prefijo; ajusta si usas carpetas virtuales
    filter { prefix = "" }

    # ❗ Abortar multipart uploads incompletos a los 7 días
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    # Borrar objetos de réplica tras 30 días
    expiration { days = 30 }
  }
}


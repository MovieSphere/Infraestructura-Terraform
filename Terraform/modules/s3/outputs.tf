output "bucket_name" {
  description = "Nombre del bucket S3 creado"
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.frontend.arn
}

output "bucket_domain" {
  description = "Dominio regional del bucket"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}
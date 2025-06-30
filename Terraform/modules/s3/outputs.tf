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

output "frontend_bucket_arn" {
  description = "ARN of the frontend bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_logs_bucket_arn" {
  description = "ARN of the frontend logs bucket"
  value       = aws_s3_bucket.frontend_logs.arn
}

output "frontend_replica_bucket_arn" {
  description = "ARN of the frontend replica bucket"
  value       = aws_s3_bucket.frontend_replica.arn
}

output "frontend_logs_bucket_domain_name" {
  description = "Nombre DNS completo del bucket de logs ej: my-bucket.s3.amazonaws.com"
  value       = aws_s3_bucket.frontend_logs.bucket_domain_name
}

output "frontend_logs_bucket_regional_domain_name" {
  description = "Nombre DNS regional del bucket de logs ej: my-bucket.s3.us-east-1.amazonaws.com"
  value       = aws_s3_bucket.frontend_logs.bucket_regional_domain_name
}

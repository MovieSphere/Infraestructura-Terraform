output "logs_bucket_name" {
  description = "Nombre del bucket S3 para logs"
  value       = aws_s3_bucket.logs.bucket
}

output "logs_bucket_arn" {
  description = "ARN del bucket S3 para logs"
  value       = aws_s3_bucket.logs.arn
}

output "api_gateway_log_group_name" {
  description = "Nombre del log group para API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway.name
} 
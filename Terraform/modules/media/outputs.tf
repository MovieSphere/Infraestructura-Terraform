output "media_bucket_name" {
  description = "Nombre del bucket de medios"
  value       = aws_s3_bucket.media.id
}

output "media_bucket_arn" {
  description = "ARN del bucket de medios"
  value       = aws_s3_bucket.media.arn
}
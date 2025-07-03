output "distribution_id" {
  description = "ID de la distribución de CloudFront"
  value       = aws_cloudfront_distribution.cdn.id
}

output "distribution_arn" {
  description = "ARN de la distribución de CloudFront"
  value       = aws_cloudfront_distribution.cdn.arn
}

output "distribution_domain_name" {
  description = "Domain name de la distribución de CloudFront"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "origin_access_identity_iam_arn" {
  description = "IAM ARN del Origin Access Identity"
  value       = aws_cloudfront_origin_access_identity.oai.iam_arn
}
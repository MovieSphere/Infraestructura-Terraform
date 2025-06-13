output "cloudfront_domain_name" {
  description = "Dominio de distribución CloudFront"
  value       = aws_cloudfront_distribution.cdn.domain_name
}
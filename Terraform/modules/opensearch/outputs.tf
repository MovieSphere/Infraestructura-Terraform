output "opensearch_endpoint" {
  description = "Endpoint URL del dominio OpenSearch"
  value       = aws_opensearch_domain.moviesphere.endpoint
}

output "opensearch_domain_arn" {
  description = "ARN del dominio OpenSearch"
  value       = aws_opensearch_domain.moviesphere.arn
}

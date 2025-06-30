output "opensearch_endpoint" {
  description = "Endpoint URL del dominio OpenSearch"
  value       = aws_opensearch_domain.moviesphere.endpoint
}

output "opensearch_domain_arn" {
  description = "ARN del dominio OpenSearch"
  value       = aws_opensearch_domain.moviesphere.arn
}

output "opensearch_security_group_id" {
    description = "ID del Security Group asociado al dominio OpenSearch"
    value       = aws_security_group.opensearch_sg.id
}

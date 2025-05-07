# Este recurso define la salida de la VPC principal para el entorno AWS.
output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.main.id
}

# Este recurso define la salida de la tabla de rutas pública para el entorno AWS.
output "public_subnet_route_table" {
  description = "Tabla de rutas pública"
  value       = aws_route_table.public.id
}

# Este recurso define la salida de la subred pública para el entorno AWS.
output "public_subnet_ids" {
  description = "IDs de las subredes públicas"
  value       = aws_subnet.public[*].id
}

# Este recurso define la salida de la subred privada para el entorno AWS.
output "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  value       = aws_subnet.private[*].id
}

# Este recurso define la salida de la puerta de enlace de internet para el entorno AWS.
output "internet_gateway_id" {
  description = "ID de la puerta de enlace de internet"
  value       = aws_internet_gateway.gw.id
}

# Endpoint del sitio web estático (VERSIÓN CORREGIDA)
output "s3_website_endpoint" {
  description = "URL del sitio web estático S3"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint  # Nueva referencia
}

# Este recurso define la salida del dominio de la distribución de CloudFront.
output "cloudfront_domain" {
  description = "Dominio de la distribución CloudFront"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

# Certificado ACM
resource "aws_acm_certificate" "moviesphere_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags = {
    Name        = "${var.project_name}-os-domain"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Validación del certificado (sin gestionar registros DNS manualmente)
resource "aws_acm_certificate_validation" "moviesphere_cert_validation" {
  certificate_arn         = aws_acm_certificate.moviesphere_cert.arn
  validation_record_fqdns = [for option in aws_acm_certificate.moviesphere_cert.domain_validation_options : option.resource_record_name]
}

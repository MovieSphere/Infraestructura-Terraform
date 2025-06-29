# Certificado ACM
resource "aws_acm_certificate" "moviesphere_cert" {
  domain_name       = "moviesphere.strategyec.com"
  validation_method = "DNS"
  tags = {
    Name        = "${var.project_name}-os-domain"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Validación del certificado (ahora con registros DNS gestionados)
resource "aws_acm_certificate_validation" "moviesphere_cert_validation" {
  certificate_arn         = aws_acm_certificate.moviesphere_cert.arn
  # validation_record_fqdns = [for record in aws_route53_record.cert_validation_records : record.fqdn]
}

# Registros DNS de validación para Route 53
/*resource "aws_route53_record" "cert_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.moviesphere_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}
*/
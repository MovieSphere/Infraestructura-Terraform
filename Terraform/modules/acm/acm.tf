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

resource "aws_route53_record" "moviesphere_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.moviesphere_cert.domain_validation_options : dvo.domain_name => dvo
  }
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  zone_id = var.zone_id
  records = [each.value.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "moviesphere_cert_validation" {
  certificate_arn         = aws_acm_certificate.moviesphere_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.moviesphere_cert_validation : record.fqdn]
}

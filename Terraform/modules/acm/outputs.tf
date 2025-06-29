output "moviesphere_cert_arn" {
  value = aws_acm_certificate.moviesphere_cert.arn
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.moviesphere_cert.arn
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.moviesphere_cert_validation.certificate_arn
}
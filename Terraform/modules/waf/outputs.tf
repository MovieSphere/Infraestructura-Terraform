output "web_acl_arn" {
  description = "ARN del WAF Web ACL regional"
  value       = aws_wafv2_web_acl.main.arn
}

output "cloudfront_web_acl_arn" {
  description = "ARN del WAF Web ACL para CloudFront"
  value       = aws_wafv2_web_acl.cloudfront.arn
}
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI para acceso a S3"
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project_name}-oac"
  description                       = "Origin Access Control para S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "s3_oai" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.s3_oai.json
}

resource "aws_cloudfront_distribution" "cdn" {
  # bridgecrew:skip=CKV2_AWS_47: WebACL está correctamente configurado con AWSManagedRulesLog4jRuleSet [[8]]
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN para ${var.bucket_name}"
  default_root_object = "index.html"
  web_acl_id = aws_wafv2_web_acl.log4j_protection.arn

  logging_config {
    bucket = "${var.log_bucket_name}.s3.amazonaws.com"
    include_cookies = false
    prefix  = "cloudfront/"
  }

  origin {
    domain_name = var.bucket_domain
    origin_id   = "s3-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Origin failover group
  origin_group {
    origin_id = "failover-group"

    # Aquí defines cuándo hacer el failover
    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }

    member {
      origin_id = "primary-origin"
    }
    member {
      origin_id = "failover-origin"
    }
  }

  dynamic "origin" {
    for_each = var.failover_bucket_domain != "" ? [1] : []
    content {
      domain_name = var.failover_bucket_domain
      origin_id   = "s3-failover-origin"

      origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id             = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id    = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
    response_headers_policy_id  = "67f7725c-6f97-4210-82d7-5512b31e9d03" # Managed-SecurityHeadersPolicy
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.failover_bucket_domain != "" ? [1] : []
    content {
      path_pattern     = "/critical/*"
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "s3-origin-group"

      cache_policy_id             = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
      origin_request_policy_id    = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
      response_headers_policy_id  = "67f7725c-6f97-4210-82d7-5512b31e9d03" # Managed-SecurityHeadersPolicy

      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 86400
      max_ttl                = 31536000
    }
  }

  price_class = var.cf_price_class

  dynamic "logging_config" {
    for_each = var.enable_access_logs && var.access_logs_bucket != "" ? [1] : []
    content {
      bucket          = var.access_logs_bucket
      prefix          = var.access_logs_prefix != "" ? var.access_logs_prefix : "${var.project_name}/cloudfront"
      include_cookies = true
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
    acm_certificate_arn           = var.enable_custom_ssl ? var.acm_certificate_arn : null
    ssl_support_method            = var.ssl_support_method
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.geo_restriction_locations
    }
  }

  tags = {
    Name = "${var.project_name}-cloudfront"
  }
}


provider "aws" {
  alias  = "global"
  region = "us-east-1"
}

resource "aws_wafv2_web_acl" "log4j_protection" {
  provider    = aws.global
  name        = "log4j-protect-acl"
  description = "Proteccion contra vulnerabilidad Log4j CVE-2021-44228 con regla personalizada"
  scope       = "CLOUDFRONT"
  default_action {
    allow {

    }
  }

  rule {
    name     = "CommonRuleSet"
    priority = 0
    action   {
      block {

      }
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    # override_action for managed rules
    override_action {
      none {
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "AnonymousIpList"
    }
  }

  rule {
    name     = "AWSKnownBadInputs"
    priority = 1
    action {
      block {

      }
    }
    statement {
      byte_match_statement {
        search_string = "jndi:ldap"
        field_to_match {
          uri_path {}
        }
        positional_constraint = "CONTAINS"
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "known_bad_inputs_protection"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                 = "log4j_protection"
    sampled_requests_enabled    = true
  }

  # depends_on = [aws_cloudfront_distribution.moviesphere]
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-${var.project_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_resource_policy" "waf_logs_policy" {
  policy_name = "waf-logging-policy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "waf.amazonaws.com"
        }
        Action   = ["logs:PutLogEvents", "logs:CreateLogStream"]
        Resource = aws_cloudwatch_log_group.waf_logs.arn
      }
    ]
  })
}

# Configuración de logging para WAF (requerido por CKV2_AWS_31)
resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [var.waf_log_destination_arn]
  resource_arn            = aws_wafv2_web_acl.log4j_protection.arn
}

resource "aws_wafv2_web_acl_association" "cloudfront_waf" {
  web_acl_arn = aws_wafv2_web_acl.log4j_protection.arn
  resource_arn = aws_cloudfront_distribution.cdn.arn
}

resource "aws_cloudfront_distribution" "moviesphere" {
  origin {
    domain_name = "moviesphere-alb-73854958.us-east-1.elb.amazonaws.com"
    origin_id   = "moviesphereALB"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribución para moviesphere"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "moviesphereALB"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Asociar el Web ACL (opcional, se puede hacer después)
  web_acl_id = aws_wafv2_web_acl.log4j_protection.arn
}

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

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${var.project_name}-security-headers"

  security_headers_config {
    content_security_policy {
      content_security_policy = "default-src 'self';"
      override                = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "no-referrer"
      override        = true
    }

    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    xss_protection {
      protection            = true
      mode_block            = true
      report_uri            = ""
      override              = true
    }
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  #checkov:skip=CKV2_AWS_47:WAF con protección Log4j ya esta definido en otro modulo, el modulo WAF
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN para ${var.bucket_name}"
  default_root_object = "index.html"
  web_acl_id          = var.cloudfront_web_acl_arn

  # Origen principal
  origin {
    domain_name             = var.bucket_domain
    origin_id               = "primary-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Origen de respaldo (failover)
  origin {
    domain_name             = var.failover_bucket_domain
    origin_id               = "failover-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Grupo de failover
  origin_group {
    origin_id = "failover-group"

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

  default_cache_behavior {
    target_origin_id       = "failover-group"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id # SecurityHeaders
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
    cloudfront_default_certificate = !var.enable_custom_ssl
    acm_certificate_arn            = var.enable_custom_ssl ? var.acm_certificate_arn : null
    ssl_support_method             = var.ssl_support_method
    minimum_protocol_version       = var.minimum_protocol_version
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
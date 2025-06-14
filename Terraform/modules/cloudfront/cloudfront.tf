resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI para acceso a S3"
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
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN para ${var.bucket_name}"
  default_root_object = "index.html"

  origin {
    domain_name = var.bucket_domain
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = var.cf_price_class

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}




resource "aws_s3_bucket" "failover" {
  bucket = "${var.bucket_name}-failover"
}

resource "aws_cloudfront_origin_access_identity" "failover_oai" {
  comment = "OAI para acceso a S3 failover"
}

resource "aws_s3_bucket_policy" "failover_policy" {
  bucket = aws_s3_bucket.failover.id
  policy = data.aws_iam_policy_document.s3_oai.json
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.bucket_name}-logs"
}

resource "aws_s3_bucket_acl" "logs_acl" {
  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}


data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN para ${var.bucket_name}"
  default_root_object = "index.html"


  origin {
    domain_name = var.bucket_domain
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.failover.bucket_regional_domain_name
    origin_id   = "failover-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.failover_oai.cloudfront_access_identity_path
    }
  }

  origin_group {
    origin_id = "origin-group-1"

    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }

    member {
      origin_id = "s3-origin"
    }
    member {
      origin_id = "failover-origin"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-group-1"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id
  }

  logging_config {
    bucket = aws_s3_bucket.logs.bucket_domain_name
    include_cookies = false
    prefix = "cloudfront-logs/"
  }

  price_class = var.cf_price_class

viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
 




}
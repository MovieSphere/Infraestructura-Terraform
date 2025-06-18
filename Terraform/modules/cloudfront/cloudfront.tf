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

  logging_config {
    bucket = "${var.log_bucket_name}.s3.amazonaws.com"
    include_cookies = false
    prefix  = "cloudfront/"
  }

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
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
       restriction_type = "whitelist"
      locations        = ["US"]
    }
  }
}
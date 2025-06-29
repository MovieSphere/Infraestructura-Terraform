resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project_name}-web-acl"
  description = "WAF Web ACL para proteger recursos"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Regla para bloquear IPs maliciosas
  rule {
    name     = "KnownBadInputs-Log4j"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsLog4j"
      sampled_requests_enabled   = true
    }
  }

  # Regla para protección contra Log4j
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
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Log4jVulnerabilityProtection"
    priority = 5

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            search_string         = "jndi:ldap://"
            positional_constraint = "CONTAINS"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
        statement {
          byte_match_statement {
            search_string         = "jndi:rmi://"
            positional_constraint = "CONTAINS"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Log4jVulnerabilityProtectionMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Log4jHeaderProtection"
    priority = 6

    action {
      block {}
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            search_string         = "jndi:"
            positional_constraint = "CONTAINS"
            field_to_match {
              single_header {
                name = "user-agent"
              }
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
        statement {
          byte_match_statement {
            search_string         = "jndi:"
            positional_constraint = "CONTAINS"
            field_to_match {
              single_header {
                name = "referer"
              }
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
        statement {
          byte_match_statement {
            search_string         = "jndi:"
            positional_constraint = "CONTAINS"
            field_to_match {
              single_header {
                name = "x-forwarded-for"
              }
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Log4jHeaderProtectionMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regla para protección contra SQL Injection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regla para limitar tasa de requests
  rule {
    name     = "RateLimitRule"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-web-acl-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "${var.project_name}-web-acl"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count = var.enable_waf_logging ? 1 : 0
  
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs[0].arn]
  resource_arn            = aws_wafv2_web_acl.main.arn

  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "KEEP"
      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}

# Kinesis Firehose para logs de WAF
resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
  count = var.enable_waf_logging ? 1 : 0
  name  = "${var.project_name}-waf-logs"

  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role[0].arn
    bucket_arn = var.waf_logs_bucket_arn
    prefix     = "waf-logs/"
  }
}

# IAM role para Firehose
resource "aws_iam_role" "firehose_role" {
  count = var.enable_waf_logging ? 1 : 0
  name  = "${var.project_name}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

# Política para Firehose
resource "aws_iam_role_policy" "firehose_policy" {
  count = var.enable_waf_logging ? 1 : 0
  name  = "${var.project_name}-firehose-policy"
  role  = aws_iam_role.firehose_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${var.waf_logs_bucket_arn}/*"
      }
    ]
  })
}

# WAF Web ACL para CloudFront (scope GLOBAL)
resource "aws_wafv2_web_acl" "cloudfront" {
  name        = "${var.project_name}-cloudfront-web-acl"
  description = "WAF Web ACL para CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Regla para bloquear IPs maliciosas
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regla para protección contra Log4j
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
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Log4jVulnerabilityProtection"
    priority = 5

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            search_string         = "jndi:ldap://"
            positional_constraint = "CONTAINS"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
        statement {
          byte_match_statement {
            search_string         = "jndi:rmi://"
            positional_constraint = "CONTAINS"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Log4jVulnerabilityProtectionMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Log4jHeaderProtection"
    priority = 6

    action {
      block {}
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            search_string         = "jndi:"
            positional_constraint = "CONTAINS"
            field_to_match {
              single_header {
                name = "user-agent"
              }
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
        statement {
          byte_match_statement {
            search_string         = "jndi:"
            positional_constraint = "CONTAINS"
            field_to_match {
              single_header {
                name = "referer"
              }
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
        statement {
          byte_match_statement {
            search_string         = "jndi:"
            positional_constraint = "CONTAINS"
            field_to_match {
              single_header {
                name = "x-forwarded-for"
              }
            }
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Log4jHeaderProtectionMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-cloudfront-web-acl-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "${var.project_name}-cloudfront-web-acl"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "cloudfront" {
  count = var.enable_waf_logging ? 1 : 0
  
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_cloudfront_logs[0].arn]
  resource_arn            = aws_wafv2_web_acl.cloudfront.arn

  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "KEEP"
      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}

# Kinesis Firehose para logs de WAF CloudFront
resource "aws_kinesis_firehose_delivery_stream" "waf_cloudfront_logs" {
  count = var.enable_waf_logging ? 1 : 0
  name  = "${var.project_name}-waf-cloudfront-logs"

  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role[0].arn
    bucket_arn = var.waf_logs_bucket_arn
    prefix     = "waf-cloudfront-logs/"
  }
} 
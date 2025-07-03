resource "aws_sns_topic" "alerts_topic" {
  name = "${var.project_name}-alerts"
  kms_master_key_id = var.sns_kms_key_id != "" ? var.sns_kms_key_id : null
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.log_kms_key_id != "" ? var.log_kms_key_id : null
}

# Metric Filter para contar cada línea que contenga "ERROR"
resource "aws_cloudwatch_log_metric_filter" "error_count_filter" {
  name           = "${var.project_name}-ErrorCount"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
  pattern        = "{ $.level = \"ERROR\" }"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "${var.project_name}/Metrics"
    value     = "1"
  }
}

# Alarma que se dispara si en 5 min hay > 10 errores
resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "${var.project_name}-ErrorAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.error_count_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.error_count_filter.metric_transformation[0].namespace
  statistic           = "Sum"
  period              = 300
  threshold           = 10
  alarm_description   = "Se dispara cuando hay más de 10 errores en 5 minutos"
  alarm_actions       = [aws_sns_topic.alerts_topic.arn]
}

resource "aws_sns_topic_policy" "allow_s3_publish" {
  arn = aws_sns_topic.alerts_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowS3Publish"
        Effect    = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.alerts_topic.arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

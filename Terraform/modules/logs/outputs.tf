output "alerts_topic_arn" {
  description = "ARN del SNS Topic de alertas"
  value       = aws_sns_topic.alerts_topic.arn
}

output "log_group_name" {
  description = "Nombre del CloudWatch Log Group creado"
  value       = aws_cloudwatch_log_group.app_logs.name
}
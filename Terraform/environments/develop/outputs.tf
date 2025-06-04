output "alb_dns_name" {
  description = "DNS del ALB para acceder a la aplicación"
  value       = module.alb.alb_dns_name
}

output "cloudwatch_dashboard_name" {
  value = module.cloudwatch.dashboard_name
}

output "sns_alerts_topic_arn" {
  value = module.monitoring.alerts_topic_arn
}

output "log_group" {
  value = module.monitoring.log_group_name
}

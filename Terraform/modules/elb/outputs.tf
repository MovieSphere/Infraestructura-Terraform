output "alb_dns_name" {
  description = "DNS del Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "target_group_arn" {
  description = "ARN del Target Group"
  value       = aws_lb_target_group.tg.arn
}
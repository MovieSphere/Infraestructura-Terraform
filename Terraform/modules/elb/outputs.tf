output "alb_id" {
  description = "ID del Application Load Balancer"
  value       = aws_lb.app_alb.id
}

output "alb_arn" {
  description = "ARN del Application Load Balancer"
  value       = aws_lb.app_alb.arn
}

output "alb_dns_name" {
  description = "DNS del Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "target_group_arn" {
  description = "ARN del target group principal"
  value       = aws_lb_target_group.tg.arn
}

output "target_group_auth_arn" {
  description = "ARN del target group de autenticación"
  value       = aws_lb_target_group.tg_auth.arn
}

output "target_group_user_arn" {
  description = "ARN del target group de usuario"
  value       = aws_lb_target_group.tg_user.arn
}
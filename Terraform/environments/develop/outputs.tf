output "alb_dns_name" {
  description = "DNS del ALB para acceder a la aplicación"
  value       = module.alb.alb_dns_name
}

output "cloudwatch_dashboard_name" {
  value = module.cloudwatch.dashboard_name
}

output "media_bucket_name" {
  value = module.media.media_bucket_name
}

output "media_bucket_arn" {
  value = module.media.media_bucket_arn
}

output "vpc_id" {
  description = "ID de la VPC creada por el módulo vpc"
  value       = module.vpc.vpc_id
}

output "alb_sg_id" {
  description = "ID del Security Group del ALB"
  value       = module.security.alb_sg_id
}

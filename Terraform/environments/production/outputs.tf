output "media_bucket_name" {
  value = module.media.media_bucket_name
}

output "media_bucket_arn" {
  value = module.media.media_bucket_arn
}

output "alb_dns_name" {
  description = "DNS del ALB para acceder a la aplicación"
  value       = module.alb.alb_dns_name
}

output "cloudwatch_dashboard_name" {
  value = module.cloudwatch.dashboard_name
}

output "mongodb_endpoint" {
  value = module.mongodb.docdb_endpoint
}

output "redis_endpoint" {
  value = module.redis.memorydb_endpoint
}
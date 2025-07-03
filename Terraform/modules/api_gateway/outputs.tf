output "api_id" {
  description = "ID del API Gateway"
  value       = aws_apigatewayv2_api.http_api.id
}

output "api_arn" {
  description = "ARN del API Gateway"
  value       = aws_apigatewayv2_api.http_api.arn
}

output "api_endpoint" {
  description = "Endpoint del API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "stage_arn" {
  description = "ARN del stage del API Gateway"
  value       = aws_apigatewayv2_stage.default.arn
}
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "api_gw_access" {
  name              = "/${var.project_name}/api-gw"
  retention_in_days = 365      # Retiene logs al menos 1 año para cumplir CKV_AWS_338
  kms_key_id        = var.kms_key_id != "" ? var.kms_key_id : null
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway.arn
      format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        caller         = "$context.identity.caller"
        user           = "$context.identity.user"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        resourcePath   = "$context.resourcePath"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
      })
    }
  }
}
  
resource "aws_apigatewayv2_authorizer" "client_cert" {
  count = var.enable_client_cert_auth ? 1 : 0
  
  api_id           = aws_apigatewayv2_api.http_api.id
  name             = "${var.project_name}-client-cert-authorizer"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  
  jwt_configuration {
    audience = [var.client_cert_audience]
    issuer   = var.client_cert_issuer
  }
}

resource "aws_apigatewayv2_integration" "http_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "https://${var.integration_uri}"
  integration_method = "ANY"
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "/aws/apigateway/${var.project_name}"
  retention_in_days = 365

  kms_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = {
    Name = "${var.project_name}-api-gateway-logs"
  }
}

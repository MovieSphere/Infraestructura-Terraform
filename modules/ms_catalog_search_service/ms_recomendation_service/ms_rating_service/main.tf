resource "aws_lambda_function" "this" {
  function_name = "ms_catalog_search_service"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  
  # Esto lo completaremos después con la ubicación del código
  filename      = "${path.module}/code.zip"
  
  # Configuración de logs
  environment {
    variables = {
      LOG_PATH = "/var/task/logs/"
    }
  }
}

# Recurso de ejemplo (personalizar según necesidad)
resource "aws_s3_bucket" "data" {
  bucket = "catalog-data-${var.environment}"
}
# CloudWatch Alarm para EC2 CPU
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "${var.project_name}-ec2-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "90"
  alarm_description  = "Alarma cuando el uso de CPU supera el 90%"
  alarm_actions      = []
  
  dimensions = {
    InstanceId = aws_instance.app_server.id
  }
}

# CloudWatch Alarm para EC2 Memoria
resource "aws_cloudwatch_metric_alarm" "ec2_memory" {
  alarm_name          = "${var.project_name}-ec2-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "Alarma cuando el uso de memoria supera el 80%"
  alarm_actions      = []
  
  dimensions = {
    InstanceId = aws_instance.app_server.id
  }
}

# CloudWatch Log Group para Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.app_lambda.function_name}"
  retention_in_days = 7 
}

# CloudWatch Alarm para errores de Lambda
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "Alarma cuando hay errores en la función Lambda"
  alarm_actions      = []
  
  dimensions = {
    FunctionName = aws_lambda_function.app_lambda.function_name
  }
}

# CloudWatch Alarm para S3
resource "aws_cloudwatch_metric_alarm" "s3_errors" {
  alarm_name          = "${var.project_name}-s3-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "Alarma cuando hay errores 4xx en el bucket S3"
  alarm_actions      = []
  
  dimensions = {
    BucketName = aws_s3_bucket.frontend.id
  }
}

# CloudWatch Dashboard básico
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.app_server.id]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.app_lambda.function_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "Lambda Invocations"
        }
      }
    ]
  })
} 
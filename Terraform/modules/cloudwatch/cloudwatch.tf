# Grupo de logs para auditoría
resource "aws_cloudwatch_log_group" "os_audit" {
  name              = "/os/${var.project_name}/audit-logs"
  retention_in_days = 365
  kms_key_id        = var.kms_key_id
}

# Grupo de logs para índices lentos
resource "aws_cloudwatch_log_group" "os_index_slow" {
  name              = "/os/${var.project_name}/index-slow-logs"
  retention_in_days = 365
  kms_key_id        = var.kms_key_id
}

# Grupo de logs para búsquedas lentas
resource "aws_cloudwatch_log_group" "os_search_slow" {
  name              = "/os/${var.project_name}/search-slow-logs"
  retention_in_days = 365
  kms_key_id        = var.kms_key_id
}

# Alarma de CPU
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "${var.project_name}-ec2-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Alarma cuando el uso de CPU supera el 90%"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = var.ec2_instance_id
  }
}

# Alarma de memoria
resource "aws_cloudwatch_metric_alarm" "ec2_memory" {
  alarm_name          = "${var.project_name}-ec2-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarma cuando el uso de memoria supera el 80%"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = var.ec2_instance_id
  }
}

# Dashboard
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
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.ec2_instance_id]
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
            ["System/Linux", "MemoryUtilization", "InstanceId", var.ec2_instance_id]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "EC2 Memory Utilization"
        }
      }
    ]
  })
}

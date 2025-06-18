output "aws_iam_instance_profile" {
  description = "Nombre del perfil de instancia IAM para CloudWatch"
  value       = aws_iam_instance_profile.cloudwatch_profile.name
}

output "flow_logs_role_arn" {
  description = "ARN del rol IAM para VPC Flow Logs"
  value       = aws_iam_role.flow_logs_role.arn
}
output "aws_iam_instance_profile" {
  description = "Nombre del perfil de instancia IAM para CloudWatch"
  value       = aws_iam_instance_profile.cloudwatch_profile.name
}
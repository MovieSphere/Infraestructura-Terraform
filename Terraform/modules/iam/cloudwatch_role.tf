resource "aws_iam_role" "cloudwatch_agent" {
  name = "${var.project_name}-cloudwatch-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
  tags = {
    Name = "${var.project_name}-cloudwatch-role"
  }
}

# Adjuntar la política administrada de CloudWatch Agent
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Perfil de instancia para EC2
resource "aws_iam_instance_profile" "cloudwatch_profile" {
  name = "${var.project_name}-cloudwatch-profile"
  role = aws_iam_role.cloudwatch_agent.name
}

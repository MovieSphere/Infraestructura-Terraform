data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Rol para CloudWatch Agent en EC2
resource "aws_iam_role" "cloudwatch_agent" {
  name               = "${var.project_name}-cloudwatch-agent-role"
  path               = "/"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowAssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-cloudwatch-role"
  }
}

# Asignar política administrada de CloudWatch Agent
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Perfil de instancia EC2 para CloudWatch Agent
resource "aws_iam_instance_profile" "cloudwatch_profile" {
  name = "${var.project_name}-cloudwatch-profile"
  role = aws_iam_role.cloudwatch_agent.name
}

# Rol para VPC Flow Logs
resource "aws_iam_role" "flow_logs_role" {
  name = "${var.project_name}-flow-logs-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowVPCFlowLogsAssume",
      Effect    = "Allow",
      Principal = { Service = "vpc-flow-logs.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Política inline para VPC Flow Logs con alcance restringido
resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "${var.project_name}-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "AllowFlowLogWrite",
      Effect = "Allow",
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      
      Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/${var.project_name}-flow-logs:log-stream:*"
    }]
  })
}

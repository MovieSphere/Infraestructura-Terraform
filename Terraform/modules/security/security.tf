# EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow HTTP, HTTPS and Docker ports"
  vpc_id      = var.vpc_id

  # lifecycle {
  #   prevent_destroy = true
  # }

  egress {
    description = "Allow HTTP (80) and HTTPS (443)"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow connection to RDS PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow access to DB from EC2"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# SSH Security Group (Ansible)
resource "aws_security_group" "ssh_sg" {
  name        = "${var.project_name}-ssh-sg"
  description = "Allow SSH connection from user IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.user_ip_cidr]
  }

  egress {
    description = "Allow web traffic for updates"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ssh-sg"
  }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# API Gateway SG
resource "aws_security_group" "apigw_sg" {
  name        = "${var.project_name}-apigw-sg"
  description = "Allow private integration between API Gateway and ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-apigw-sg"
  }
}

### RULES SEPARATED TO AVOID CYCLES

# ALB --> EC2
resource "aws_security_group_rule" "alb_to_ec2" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ec2_sg.id
}

# EC2 --> RDS
resource "aws_security_group_rule" "ec2_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}

# API Gateway --> ALB
resource "aws_security_group_rule" "apigw_to_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.apigw_sg.id
  security_group_id        = aws_security_group.alb_sg.id
}

# ALB --> EC2 (simulated egress as ingress if needed)
resource "aws_security_group_rule" "alb_egress_to_ec2" {
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id        = aws_security_group.alb_sg.id
}

# API Gateway --> ALB egress
resource "aws_security_group_rule" "apigw_egress_to_alb" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.apigw_sg.id
}

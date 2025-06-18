# Módulo de Security Groups para Terraform

# Inline suppression for CKV2_AWS_5: each SG is attached in other modules

resource "aws_security_group" "ec2_sg" { # checkov:skip=CKV2_AWS_5: SG adjunto a instancias EC2 en otro módulo
  name        = "${var.project_name}-ec2-sg"
  description = "Permite solo tráfico de aplicación y DNS"
  vpc_id      = var.vpc_id

  # Ingreso: solo tráfico de la aplicación desde ALB
  ingress {
    description     = "Tráfico de la aplicación desde ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Salida: HTTP
  egress {
    description = "Salida HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: HTTPS
  egress {
    description = "Salida HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: DNS UDP
  egress {
    description = "Salida DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: DNS TCP
  egress {
    description = "Salida DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_security_group" "rds_sg" { # checkov:skip=CKV2_AWS_5: SG adjunto al clúster RDS en otro módulo
  name        = "${var.project_name}-rds-sg"
  description = "Permite PostgreSQL desde EC2 y restringe salida al VPC"
  vpc_id      = var.vpc_id

  # Ingreso: PostgreSQL solo desde EC2
  ingress {
    description     = "PostgreSQL inbound desde EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # Salida: restringida al VPC
  egress {
    description = "Salida restringida al VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_security_group" "ssh_sg" { # checkov:skip=CKV2_AWS_5: SG para SSH, adjunto en módulo Ansible/EC2
  name        = "${var.project_name}-ssh-sg"
  description = "Permite SSH desde tu IP y salida web/DNS"
  vpc_id      = var.vpc_id

  # Ingreso: SSH desde IP autorizada
  ingress {
    description = "SSH inbound desde IP del usuario"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.user_ip_cidr]
  }

  # Salidas necesarias: HTTP, HTTPS, DNS UDP/TCP
  egress {
    description = "Salida HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Salida HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Salida DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Salida DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ssh-sg"
  }
}

resource "aws_security_group" "alb_sg" { # checkov:skip=CKV2_AWS_5: SG para ALB, asociado en módulo ALB
  name        = "${var.project_name}-alb-sg"
  description = "Permite HTTP desde API Gateway y salida a EC2"
  vpc_id      = var.vpc_id

  # Ingreso: HTTP desde API Gateway
  ingress {
    description     = "Tráfico HTTP desde API Gateway"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.apigw_sg.id]
  }
  # Egress: app traffic to EC2
  egress {
    description     = "Salida al puerto de aplicación en EC2"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  
  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "apigw_sg" { # checkov:skip=CKV2_AWS_5: SG de API GW, asociado en módulo VPC Link/API GW
  name        = "${var.project_name}-apigw-sg"
  description = "Permite tráfico saliente HTTP a ALB"
  vpc_id      = var.vpc_id

  # Egress: HTTP a ALB
  egress {
    description     = "Salida HTTP a ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

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

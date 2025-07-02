# Módulo de Security Groups para Terraform
# Inline suppression for CKV2_AWS_5: each SG is attached in other modules
# checkov:skip=CKV2_AWS_5: SG adjunto a instancias EC2 en otro módulo

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allows app and DNS traffic"
  vpc_id      = var.vpc_id

  # Salida: HTTP
  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: HTTPS
  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: DNS UDP
  egress {
     description = "DNS UDP outbound"
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

# checkov:skip=CKV2_AWS_5: SG adjunto al clúster RDS en otro módulo
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allows PostgreSQL from EC2 and restricts egress to VPC"
  vpc_id      = var.vpc_id

  # Ingreso: PostgreSQL solo desde EC2
  ingress {
    description     = "PostgreSQL inbound from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # Salida: restringida al VPC
  egress {
    description = "Egress restricted to VPC"
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
  description = "Allows SSH from your IP and web/DNS egress"
  vpc_id      = var.vpc_id

  # Ingreso: SSH desde IP autorizada
  ingress {
    description = "SSH inbound from user IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.user_ip_cidr]
  }

  # Salidas necesarias: HTTP, HTTPS, DNS UDP/TCP
  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
     description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "DNS UDP outbound"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "DNS TCP outbound"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ssh-sg"
  }
}

# checkov:skip=CKV2_AWS_5: SG para ALB, asociado en módulo ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allows HTTP from API Gateway and egress to EC2"
  vpc_id      = var.vpc_id
  
  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# checkov:skip=CKV2_AWS_5: SG de API GW, asociado en módulo VPC Link/API GW
resource "aws_security_group" "apigw_sg" {
  name        = "${var.project_name}-apigw-sg"
  description = "Allows outbound HTTP to ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-apigw-sg"
  }
}

### RULES SEPARATED TO AVOID CYCLES

# EC2 ← ALB (ingress)
resource "aws_security_group_rule" "alb_to_ec2" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

# ALB ← API GW (ingress)
resource "aws_security_group_rule" "apigw_to_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.apigw_sg.id
}

# ALB → EC2 (egress)
resource "aws_security_group_rule" "alb_egress_to_ec2" {
  type                           = "egress"
  from_port                      = 3000
  to_port                        = 3000
  protocol                       = "tcp"
  security_group_id              = aws_security_group.alb_sg.id
  source_security_group_id      = aws_security_group.ec2_sg.id
}

# API GW → ALB (egress)
resource "aws_security_group_rule" "apigw_egress_to_alb" {
  type                           = "egress"
  from_port                      = 80
  to_port                        = 80
  protocol                       = "tcp"
  security_group_id              = aws_security_group.apigw_sg.id
  source_security_group_id      = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["34.193.55.66/32"]
  security_group_id = aws_security_group.ec2_sg.id
  description       = "Allow SSH from my public IP"
}

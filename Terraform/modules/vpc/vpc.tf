# VPC principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Subredes públicas
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }
}

# Subredes privadas
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index}"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"
  
  tags = {
    Name = "${var.project_name}-nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = {
    Name = "${var.project_name}-nat-gw-${count.index}"
  }
}


# Tabla de rutas privadas
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = { Name = "${var.project_name}-private-rt-${count.index}" }
}

# Asociación con subredes privadas
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Tabla de ruta pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-route_table"
  }
}

# Asociación de tabla de ruta con cada subred pública
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Grupo de subredes para RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

# Flow logs para VPC
resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_cloudwatch_log_group.vpc_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  iam_role_arn         = var.flow_logs_role_arn
}

data "aws_caller_identity" "current" {}

# KMS Key para los logs
resource "aws_kms_key" "cw_logs" {
  description             = "KMS key for CloudWatch VPC Flow Logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "vpc-flow-logs-key-policy",
    Statement = [
      {
        Sid    = "AllowRootAccount",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsUse",
        Effect = "Allow",
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-cw-logs-key"
  }
}


resource "aws_cloudwatch_log_group" "vpc_logs" {
  name              = "/aws/vpc/${var.project_name}-flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.cw_logs.arn

  tags = {
    Name = "${var.project_name}-flow-logs"
  }
}

# Desactiva to-do trafico en el Security Group por defecto
resource "aws_default_security_group" "restrict_default" {
  vpc_id = aws_vpc.main.id

  # Reglas de entrada vacías
  ingress = []

  # Reglas de salida vacías
  egress = []

  tags = {
    Name = "${var.project_name}-restricted-default-sg"
  }
}

# Interface Endpoint para SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_id            = aws_vpc.main.id
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [var.ec2_sg_id]
}

# Interface Endpoint para SSMMessages
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_id            = aws_vpc.main.id
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [var.ec2_sg_id]
}

# Interface Endpoint para EC2Messages
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_id            = aws_vpc.main.id
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [var.ec2_sg_id]
}

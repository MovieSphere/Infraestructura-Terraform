# EC2 Instance
resource "aws_instance" "ec2_ubuntu_docker" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release

    mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    usermod -aG docker ubuntu

    # Clonar repos
    cd /home/ubuntu
    git clone https://github.com/MovieSphere/ms_user_service.git
    git clone https://github.com/MovieSphere/ms_auth_service.git

    cat <<EOT > /home/ubuntu/docker-compose.yml
    version: "3.9"
    services:
      ms_auth:
        build:
          context: ./ms_auth_service
          dockerfile: Dockerfile
        image: ms-auth-service:latest
        container_name: ms-auth-service
        ports:
          - "3001:8091"
        environment:
          - SPRING_PROFILES_ACTIVE=prod
          - SPRING_DATASOURCE_URL=jdbc:postgresql://${aws_db_instance.auth_db.address}:5432/auth_db
          - SPRING_DATASOURCE_USERNAME=${var.db_username}
          - SPRING_DATASOURCE_PASSWORD=${var.db_password}
        restart: unless-stopped

      ms_user:
        build:
          context: ./ms_user_service
          dockerfile: Dockerfile
        image: ms-user-service:latest
        container_name: ms-user-service
        ports:
          - "3002:8092"
        environment:
          - SPRING_PROFILES_ACTIVE=prod
          - SPRING_DATASOURCE_URL=jdbc:postgresql://${aws_db_instance.users_db.address}:5432/users_db
          - SPRING_DATASOURCE_USERNAME=${var.db_username}
          - SPRING_DATASOURCE_PASSWORD=${var.db_password}
        restart: unless-stopped
    EOT

    chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml

    su - ubuntu -c "docker compose -f /home/ubuntu/docker-compose.yml up -d"
  EOF

  tags = {
    Name = "${var.project_name}-ec2-ubuntu-docker"
  }
}

resource "aws_security_group" "docker_sg" {
  name        = "docker-sg"
  description = "Allow access to Docker microservices"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3001
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

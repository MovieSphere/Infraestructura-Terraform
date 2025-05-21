#!/bin/bash

# Instalación de Docker Engine por medio del repositorio APT para Ubuntu
# Actualizar e instalar herramientas necesarias
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release git

# Instalar Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
> /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Agregar usuario ubuntu al grupo docker
usermod -aG docker ubuntu

# Crear estructura en /home/ubuntu
runuser -l ubuntu -c "
  mkdir -p ~/infra_ms && cd ~/infra_ms

  # Clonar repositorios
  git clone https://github.com/MovieSphere/ms_user_service.git
  git clone https://github.com/MovieSphere/ms_auth_service.git

  # Crear archivo .env
  cat <<EOT > .env
MS_AUTH_DB_URL=jdbc:postgresql://${auth_db_host}:5432/authdb
MS_USER_DB_URL=jdbc:postgresql://${user_db_host}:5432/userdb
DB_USERNAME=${db_username}
DB_PASSWORD=${db_password}
EOT

  # Crear archivo docker-compose.yml
  cat <<EOT > docker-compose.yml
version: '3.8'
services:
  ms_auth_service:
    build:
      context: ./ms_auth_service
    container_name: ms_auth_service
    ports:
      - '8091:8091'
    environment:
      DB_URL: \$\${MS_AUTH_DB_URL}
      DB_USERNAME: \$\${DB_USERNAME}
      DB_PASSWORD: \$\${DB_PASSWORD}
    depends_on: []

  ms_user_service:
    build:
      context: ./ms_user_service
    container_name: ms_user_service
    ports:
      - '8092:8092'
    environment:
      DB_URL: \$\${MS_USER_DB_URL}
      DB_USERNAME: \$\${DB_USERNAME}
      DB_PASSWORD: \$\${DB_PASSWORD}
    depends_on: []
EOT

  # Levantar los microservicios
  docker compose --env-file .env up -d
"

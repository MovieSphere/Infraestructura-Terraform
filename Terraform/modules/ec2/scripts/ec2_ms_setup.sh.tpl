#!/bin/bash

# Instalación de Docker Engine por medio del repositorio APT para Ubuntu
# Actualizar e instalar herramientas necesarias y la instalación de amazon cloudwatch agent
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release git amazon-cloudwatch-agent

# Instalar Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
> /etc/apt/sources.list.d/docker.list

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/moviesphere/messages",
            "log_stream_name": "{instance_id}-messages"
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/moviesphere/nginx/access",
            "log_stream_name": "{instance_id}-nginx-access"
          },
          {
            "file_path": "/var/lib/docker/containers/*/*.log",
            "log_group_name": "/moviesphere/docker",
            "log_stream_name": "{instance_id}-docker"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

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
  git clone https://github.com/MovieSphere/ms_catalog_service.git

  git clone https://github.com/MovieSphere/ms_movie_service.git
  git clone https://github.com/MovieSphere/ms_actor_service.git
  git clone https://github.com/MovieSphere/ms_rating_service.git
  git clone https://github.com/MovieSphere/ms_recomendation_service.git
  git clone https://github.com/MovieSphere/ms_catalog_search_service.git


  # Crear archivo .env
  cat <<EOT > .env
  MS_AUTH_DB_URL=${MS_AUTH_DB_URL}
  MS_USER_DB_URL=${MS_USER_DB_URL}
  MS_CATALOG_DB_URL=${MS_CATALOG_DB_URL}
  DB_USERNAME=${DB_USERNAME}
  DB_PASSWORD=${DB_PASSWORD}
  OPENSEARCH_URL=${OPENSEARCH_URL}
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
    volumes:
      - shared-logs:/app/logs
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
    volumes:
      - shared-logs:/app/logs
    depends_on: []



  ms_movie_service:
    build:
      context: ./ms_movie_service
    container_name: ms_movie_service
    ports:
      - '8093:8093'
    environment:
      # Variables por añadir
    depends_on: []

  ms_actor_service:
    build:
      context: ./ms_actor_service
    container_name: ms_actor_service
    ports:
      - '8094:8094'
    environment:
      # Variables por añadir
    depends_on: []

    ms_catalog_service:
    build:
      context: ./ms_catalog_service
    container_name: ms_catalog_service
    ports:
      - '8093:8093'
    environment:
      DB_URL: \$\${MS_CATALOG_DB_URL}
      DB_USERNAME: \$\${DB_USERNAME}
      DB_PASSWORD: \$\${DB_PASSWORD}
    depends_on: []

  ms_rating_service:
    build:
      context: ./ms_rating_service
    container_name: ms_rating_service
    ports:
      - '8095:8095'
    environment:
      # Variables por añadir
    depends_on: []

  ms_recomendation_service:
    build:
      context: ./ms_recomendation_service
    container_name: ms_recomendation_service
    ports:
      - '8096:8096'
    environment:
      OPENSEARCH_URL: \$\${OPENSEARCH_URL}
    depends_on: []

  ms_catalog_search_service:
    build:
      context: ./ms_catalog_search_service
    container_name: ms_catalog_search_service
    ports:
      - '8097:8097'
    environment:
      OPENSEARCH_URL: \$\${OPENSEARCH_URL}
    depends_on: []
EOT

  # Levantar los microservicios
  docker compose --env-file .env up -d
"

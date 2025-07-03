FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    python3 \
    python3-pip \
    python3-venv \
    python3-full \
    pipx \
    jq \
    awscli \
    software-properties-common \
    gnupg \
    lsb-release \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Instalar Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

# Instalar Checkov usando pipx
RUN pipx install checkov && \
    pipx ensurepath

# Crear usuario jenkins
RUN useradd -m -s /bin/bash jenkins && \
    usermod -aG sudo jenkins

# Configurar directorio de trabajo
WORKDIR /home/jenkins/workspace

# Copiar scripts de utilidad
COPY scripts/ /home/jenkins/scripts/
RUN chmod +x /home/jenkins/scripts/*.sh && \
    chown -R jenkins:jenkins /home/jenkins

# Configurar variables de entorno
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin:/root/.local/bin
ENV AWS_DEFAULT_REGION=us-east-1

# Exponer puerto para Jenkins agent
EXPOSE 22

# Cambiar al usuario jenkins
USER jenkins

# Comando por defecto
CMD ["/bin/bash"] 
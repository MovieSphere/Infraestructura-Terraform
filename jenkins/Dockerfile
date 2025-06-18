FROM jenkins/jenkins:lts-jdk17

USER root

# Instalar dependencias básicas del sistema
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    git \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivo de plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Instalar plugins desde plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Configurar Jenkins
COPY scripts/setup-jenkins.sh /tmp/setup-jenkins.sh
RUN chmod +x /tmp/setup-jenkins.sh

# Crear directorios necesarios
RUN mkdir -p /var/jenkins_home/workspace && \
    mkdir -p /var/jenkins_home/tools && \
    mkdir -p /var/jenkins_home/plugins && \
    mkdir -p /var/jenkins_home/init.groovy.d && \
    chown -R jenkins:jenkins /var/jenkins_home

# Copiar scripts de utilidad
COPY scripts/ /var/jenkins_scripts/
RUN chmod +x /var/jenkins_scripts/*.sh && \
    chown -R jenkins:jenkins /var/jenkins_scripts

# Copiar script de inicialización Groovy
COPY init.groovy.d/ /var/jenkins_home/init.groovy.d/
RUN chown -R jenkins:jenkins /var/jenkins_home/init.groovy.d

# Configurar variables de entorno
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV JENKINS_OPTS="--httpPort=8080"

# Exponer puertos
EXPOSE 8080 50000

# Cambiar de vuelta al usuario jenkins
USER jenkins

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/login || exit 1

# Comando de inicio
CMD ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"] 
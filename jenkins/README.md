# Pipeline de Jenkins para Infraestructura Terraform

Este directorio contiene la configuración completa del pipeline de Jenkins para automatizar el despliegue de infraestructura con Terraform.

## 🏗️ Arquitectura del Pipeline

### Componentes Principales

1. **Jenkins Master**: Servidor Jenkins con plugins personalizados
2. **Agent Terraform**: Contenedor con herramientas de Terraform
3. **Scripts de Automatización**: Scripts bash para validación y despliegue

### Estructura de Directorios

```
jenkins/
├── Dockerfile                 # Imagen personalizada de Jenkins
├── plugins.txt                # Lista de plugins requeridos
├── scripts/
│   ├── setup-jenkins.sh       # Configuración inicial
│   ├── terraform-validate.sh  # Validación completa
│   └── deploy-environment.sh  # Despliegue por ambiente
└── README.md                  # Esta documentación
```

## 🚀 Inicio Rápido

### 1. Levantar el Pipeline

```bash
# Construir y levantar todos los servicios
docker-compose up -d --build

# Ver logs de Jenkins
docker-compose logs -f jenkins
```

### 2. Acceder a Jenkins

- **URL**: http://localhost:8080
- **Usuario**: admin
- **Contraseña**: admin123

### 3. Crear el Job de Pipeline

1. Ir a "New Item" en Jenkins
2. Seleccionar "Pipeline"
3. Nombrar el job (ej: "terraform-pipeline")
4. En "Pipeline", seleccionar "Pipeline script from SCM"
5. Configurar Git con el repositorio
6. Especificar el Jenkinsfile como script path

## 📋 Etapas del Pipeline

### 1. Preparación
- Configuración de variables de entorno
- Validación de credenciales AWS
- Preparación del workspace

### 2. Validación de Código (Paralelo)
- **Terraform Format**: Verifica formato del código
- **Terraform Validate**: Valida sintaxis y configuración
- **Checkov Security Scan**: Análisis de seguridad

### 3. Análisis de Módulos
- Revisión de módulos disponibles
- Verificación de dependencias
- Análisis de estructura

### 4. Plan de Infraestructura
- Generación de plan de Terraform
- Revisión de cambios propuestos
- Validación de costos estimados

### 5. Aprobación Manual (Solo Producción)
- Gate de seguridad para producción
- Revisión manual de cambios críticos

### 6. Aplicar Cambios
- Despliegue de infraestructura
- Aplicación de configuración
- Verificación de estado

### 7. Generar Outputs
- Extracción de valores de salida
- Generación de reportes
- Documentación de recursos

## 🔧 Configuración

### Plugins de Jenkins

Los plugins se gestionan a través del archivo `plugins.txt`:

```txt
# Core Plugins
workflow-aggregator:latest
pipeline-stage-view:latest
blueocean:latest

# Git Integration
git:latest
git-client:latest

# AWS Integration
aws-credentials:latest
aws-java-sdk:latest

# Terraform Integration
terraform:latest
terraform-plugin:latest

# Security Scanning
checkov:latest
sonar:latest

# Testing and Reporting
junit:latest
test-results-analyzer:latest

# Credentials Management
credentials-binding:latest
ssh-credentials:latest
plain-credentials:latest

# Docker Integration
docker-plugin:latest
docker-workflow:latest

# Pipeline Utilities
pipeline-utility-steps:latest
pipeline-build-step:latest
pipeline-input-step:latest

# Build Management
timestamper:latest
build-timeout:latest
parameterized-trigger:latest

# Conditional Builds
conditional-buildstep:latest
extended-choice-parameter:latest

# Environment Management
envinject:latest
environment-injector:latest

# Monitoring and Logging
monitoring:latest
log-rotator:latest

# UI Enhancements
simple-theme-plugin:latest
dark-theme:latest

# Additional Utilities
rebuild:latest
copyartifact:latest
```

### Variables de Entorno

```bash
# AWS Configuration
AWS_DEFAULT_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key

# Terraform Configuration
TF_VERSION=1.5.0
CHECKOV_VERSION=2.3.0
```

### Parámetros del Pipeline

- **ENVIRONMENT**: develop, production, all
- **APPLY_CHANGES**: true/false (solo para producción)
- **AWS_ACCESS_KEY_ID**: Credenciales AWS
- **AWS_SECRET_ACCESS_KEY**: Credenciales AWS

## 🛠️ Scripts Disponibles

### terraform-validate.sh

Validación completa de código Terraform:

```bash
./jenkins/scripts/terraform-validate.sh [environment]
```

**Funciones:**
- Verificación de formato
- Validación de sintaxis
- Análisis de seguridad con Checkov
- Verificación de variables

### deploy-environment.sh

Despliegue en ambientes específicos:

```bash
./jenkins/scripts/deploy-environment.sh [environment] [action]
```

**Acciones disponibles:**
- `plan`: Generar plan de Terraform
- `apply`: Aplicar cambios
- `destroy`: Destruir infraestructura
- `output`: Generar outputs

## 🔒 Seguridad

### Credenciales AWS

1. **Configuración en Jenkins:**
   - Ir a "Manage Jenkins" > "Manage Credentials"
   - Agregar credenciales AWS
   - Usar en el pipeline

2. **Variables de Entorno:**
   ```bash
   export AWS_ACCESS_KEY_ID=your_key
   export AWS_SECRET_ACCESS_KEY=your_secret
   ```

### Checkov Configuration

El archivo `.checkov.yml` en la raíz del proyecto configura las reglas de seguridad:

```yaml
skip-check:
    - CKV2_AWS_5  # Los SG están asociados a través de módulos
```

## 📊 Monitoreo y Reportes

### Logs del Pipeline

- **Jenkins UI**: Ver logs en tiempo real
- **Docker Logs**: `docker-compose logs -f jenkins`
- **Archivos de Log**: `/var/jenkins_home/workspace/`

### Reportes Generados

- **Checkov Results**: `results.xml`
- **Terraform Outputs**: `outputs_[environment].txt`
- **Deploy Reports**: `deploy_report_[environment]_[timestamp].txt`

## 🐛 Troubleshooting

### Problemas Comunes

1. **Jenkins no inicia:**
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

2. **Plugins no se instalan:**
   - Verificar archivo `plugins.txt`
   - Revisar logs de construcción
   - Limpiar caché de Docker

3. **Credenciales AWS no válidas:**
   - Verificar variables de entorno
   - Revisar configuración en Jenkins

4. **Terraform init falla:**
   - Verificar permisos de AWS
   - Revisar configuración de backend

5. **Checkov no encuentra archivos:**
   - Verificar estructura de directorios
   - Revisar configuración de Checkov

### Logs de Debug

```bash
# Ver logs de todos los servicios
docker-compose logs

# Ver logs específicos
docker-compose logs jenkins
docker-compose logs agent-terraform
```

## 🔄 Mantenimiento

### Actualización de Plugins

```bash
# Editar plugins.txt con nuevas versiones
# Reconstruir imagen con plugins actualizados
docker-compose down
docker-compose up -d --build
```

### Backup de Configuración

```bash
# Backup del volumen de Jenkins
docker run --rm -v jenkins_jenkins_home:/data -v $(pwd):/backup alpine tar czf /backup/jenkins-backup.tar.gz -C /data .
```

### Limpieza

```bash
# Limpiar contenedores y volúmenes
docker-compose down -v
docker system prune -f
```

## 📚 Recursos Adicionales

- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Checkov Documentation](https://www.checkov.io/)
- [AWS Credentials Management](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html)
- [Jenkins Plugin Management](https://www.jenkins.io/doc/book/managing/plugins/)

## 🤝 Contribución

Para contribuir al pipeline:

1. Crear una rama feature
2. Implementar cambios
3. Probar localmente
4. Crear Pull Request
5. Revisar y aprobar

## 📞 Soporte

Para problemas o preguntas:

1. Revisar la documentación
2. Verificar logs de Jenkins
3. Consultar troubleshooting
4. Crear issue en el repositorio 
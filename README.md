# MovieSphere
## Problemática Identificada
Los usuarios de plataformas de streaming suelen tener dificultades para encontrar películas que realmente se ajusten a sus gustos. Muchas veces, las recomendaciones que reciben son genéricas y poco útiles, lo que hace que la búsqueda de una película interesante sea tediosa y frustrante. Por ello, muchas personas terminan recurriendo a páginas externas para leer opiniones o críticas antes de decidir qué ver. Ante esta situación, surge la necesidad de una plataforma como Moviesphere, que facilite a los usuarios descubrir películas de forma más rápida, personalizada y con una mejor experiencia.

## Resumen del Proyecto
Moviesphere es una plataforma web de recomendación de películas personalizada, similar a IMDb, que utiliza una arquitectura moderna basada en microservicios desplegados en contenedores Docker. La aplicación está desarrollada en Spring boot para el backend y TypeScript para el frontend (Angular), y utiliza PostgreSQL como base de datos principal para sus usuarios, entre otras. La infraestructura está definida con Terraform, permitiendo separar entornos de desarrollo, pruebas (staging) y producción. Este enfoque busca escalabilidad, facilidad de mantenimiento y automatización de despliegues con herramientas como Jenkins, Ansible y Terraform.


##  Arquitectura

La infraestructura incluye:

- **VPC** con subredes públicas y privadas
- **EC2** para hosting de aplicaciones
- **Lambda** para funciones serverless
- **S3** para almacenamiento
- **CloudFront** para CDN
- **CloudWatch** para monitoreo básico

## Prerrequisitos

- AWS CLI configurado
- Terraform instalado
- Credenciales de AWS configuradas

## Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/Infraestructura-Terraform.git
cd Infraestructura-Terraform
```

2. Inicializar Terraform:
```bash
cd Terraform/environments/develop
terraform init
```

3. Revisar el plan:
```bash
terraform plan
```

4. Aplicar la infraestructura:
```bash
terraform apply
```

## Componentes

### VPC y Redes
- VPC con CIDR personalizable
- Subredes públicas y privadas
- Internet Gateway
- Tablas de rutas

### EC2
- Security Group con puertos 22 (SSH) y 80 (HTTP)
- Tags para identificación

### Lambda
- Función Python 3.9
- IAM Role con permisos mínimos
- Integración con CloudWatch Logs

### S3 y CloudFront
- Bucket S3 para frontend
- CloudFront como CDN
- Políticas de acceso seguras

### CloudWatch
- Monitoreo de EC2 (CPU)
- Logs de Lambda (7 días retención)
- Dashboard simple

## Costos

La infraestructura está diseñada para minimizar costos:
- Uso de servicios dentro del tier gratuito de AWS
- Monitoreo básico con CloudWatch
- Retención de logs reducida
- Sin VPC Endpoints costosos

## Seguridad

- Security Groups con acceso mínimo
- IAM Roles con permisos específicos
- S3 con acceso público bloqueado
- CloudFront con HTTPS

## Monitoreo

CloudWatch Dashboard incluye:
- Métricas de CPU de EC2
- Invocaciones de Lambda
- Logs de Lambda

## Limpieza

Para destruir la infraestructura:
```bash
terraform destroy
```

## ¿Cómo acceder y probar las búsquedas desde los servicios?

1. Acceder a EC2 por SSH.
2. Verificar que los contenedores estén corriendo:
   ```bash
   docker ps
   ```
3. Probar los endpoints:
   - recommendation:
     ```bash
     curl http://localhost:8096/api/recommend?q=accion
     ```
   - catalog_search:
     ```bash
     curl http://localhost:8097/api/search?q=pelicula
     ```
4. El servicio de OpenSearch deberá estar disponible en: 
     ```bash
     curl -XGET `http://<endpoint_opensearch>:9200`
     ```
    NOTA: Terraform proporcionará el endpoint el cual se reemplazará por <endpoint_opensearch>
    ejemplo: http://search-moviesphere-xxxx.region.es.amazonaws.com:9200

## 🚀 Pipeline de Jenkins para Automatización

### Descripción del Pipeline

Este proyecto incluye un pipeline completo de Jenkins para automatizar el despliegue de infraestructura con Terraform.

### Arquitectura del Pipeline

```
┌─────────────────┐    ┌─────────────────┐
│   Jenkins       │    │  Agent          │
│   Master        │    │  Terraform      │
│                 │    │                 │
│ - Pipeline      │◄──►│ - Terraform     │
│ - Plugins       │    │ - Checkov       │
│ - Credentials   │    │ - AWS CLI       │
│ - UI            │    │ - Java 11       │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┘
                    │
         ┌─────────────────┐
         │   Docker        │
         │   Compose       │
         │                 │
         │ - Networking    │
         │ - Volumes       │
         │ - Health Checks │
         └─────────────────┘
```

### Estructura del Proyecto

```
Infraestructura-Terraform/
├── jenkins/                    # Jenkins Master (Solo UI y plugins)
│   ├── Dockerfile             # Imagen básica de Jenkins
│   ├── plugins.txt            # Lista de plugins requeridos
│   ├── scripts/               # Scripts de configuración
│   ├── jobs/                  # Configuración de jobs
│   └── README.md              # Documentación de Jenkins
├── agent-terraform/           # Agente especializado (Todas las herramientas)
│   ├── Dockerfile             # Imagen con Terraform, Checkov, AWS CLI
│   ├── scripts/               # Scripts de validación
│   ├── agent-config.xml       # Configuración del agente
│   └── README.md              # Documentación del agente
├── Terraform/                 # Código de infraestructura
├── docker-compose.yml         # Orquestación de servicios
├── Jenkinsfile                # Pipeline principal
├── run-checkov.sh             # Script para ejecutar Checkov (Linux)
├── run-checkov.ps1            # Script para ejecutar Checkov (Windows)
└── start-pipeline.sh          # Script de gestión
```

### Características del Pipeline

✅ **Validación Completa**: `terraform fmt`, `terraform validate`, `checkov`  
✅ **Agente Especializado**: Contenedor dedicado con todas las herramientas  
✅ **Sin Duplicación**: Jenkins solo UI, agente solo herramientas  
✅ **Gestión de Plugins**: Archivo `plugins.txt` para control de versiones  
✅ **Múltiples Ambientes**: Soporte para develop, production y staging  
✅ **Aprobación Manual**: Gate de seguridad para producción  
✅ **Paralelización**: Ejecución paralela de validaciones  
✅ **Reportes**: Generación automática de reportes y outputs  
✅ **Limpieza**: Gestión automática de archivos temporales  

### Gestión de Plugins

Los plugins de Jenkins se gestionan a través del archivo `jenkins/plugins.txt`:

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

### Inicio Rápido del Pipeline

#### 1. Levantar el Pipeline

```bash
# Usar el script de inicio rápido
./start-pipeline.sh start

# O usar Docker Compose directamente
docker-compose up -d --build
```

#### 2. Acceder a Jenkins

- **URL**: http://localhost:8080
- **Usuario**: admin
- **Contraseña**: admin123

#### 3. Crear Job de Pipeline

1. Ir a "New Item" en Jenkins
2. Seleccionar "Pipeline"
3. Nombrar el job (ej: "terraform-pipeline")
4. En "Pipeline", seleccionar "Pipeline script from SCM"
5. Configurar Git con el repositorio
6. Especificar el Jenkinsfile como script path

### Etapas del Pipeline

#### 1. Preparación
- Configuración de variables de entorno
- Validación de credenciales AWS
- Preparación del workspace

#### 2. Validación de Código (Paralelo)
- **Terraform Format**: Verifica formato del código
- **Terraform Validate**: Valida sintaxis y configuración
- **Checkov Security Scan**: Análisis de seguridad

#### 3. Análisis de Módulos
- Revisión de módulos disponibles
- Verificación de dependencias
- Análisis de estructura

#### 4. Plan de Infraestructura
- Generación de plan de Terraform
- Revisión de cambios propuestos
- Validación de costos estimados

#### 5. Aprobación Manual (Solo Producción)
- Gate de seguridad para producción
- Revisión manual de cambios críticos

#### 6. Aplicar Cambios
- Despliegue de infraestructura
- Aplicación de configuración
- Verificación de estado

#### 7. Generar Outputs
- Extracción de valores de salida
- Generación de reportes
- Documentación de recursos

### Componentes del Pipeline

#### Jenkins Master (`jenkins/`)
- **Dockerfile**: Imagen básica solo con Jenkins y plugins
- **plugins.txt**: Gestión de plugins con versiones específicas
- **Scripts**: Configuración automática
- **Jobs**: Configuración de pipelines

#### Agent Terraform (`agent-terraform/`)
- **Dockerfile**: Imagen completa con todas las herramientas
- **Scripts**: Validación y despliegue
- **Configuración**: Variables de entorno y permisos
- **Herramientas**: Terraform, Checkov, AWS CLI, Java 11

### Scripts de Utilidad

#### Validación Local

```bash
# Validar código Terraform localmente
./start-pipeline.sh validate develop

# O usar el script del agente
./agent-terraform/scripts/terraform-validate.sh develop
```

#### Checkov Security Scan

```bash
# Ejecutar Checkov (Linux)
./run-checkov.sh

# Ejecutar Checkov (Windows PowerShell)
.\run-checkov.ps1

# Desde dentro del agente
docker exec jenkins-agent-terraform checkov --directory /home/jenkins/workspace/Terraform
```

#### Despliegue Manual

```bash
# Desplegar en ambiente específico
./jenkins/scripts/deploy-environment.sh develop plan
./jenkins/scripts/deploy-environment.sh develop apply
```

### Gestión del Pipeline

```bash
# Ver estado de servicios
./start-pipeline.sh status

# Ver logs de Jenkins
./start-pipeline.sh logs

# Reiniciar pipeline
./start-pipeline.sh restart

# Limpiar todo
./start-pipeline.sh clean
```

### Configuración de Credenciales

#### AWS Credentials

1. **En Jenkins UI:**
   - Ir a "Manage Jenkins" > "Manage Credentials"
   - Agregar credenciales AWS
   - Usar en el pipeline

2. **Variables de Entorno:**
   ```bash
   export AWS_ACCESS_KEY_ID=your_key
   export AWS_SECRET_ACCESS_KEY=your_secret
   ```

#### Checkov Configuration

El archivo `.checkov.yml` configura las reglas de seguridad:

```yaml
skip-check:
    - CKV2_AWS_5  # Los SG están asociados a través de módulos
```

### Monitoreo y Reportes

#### Logs del Pipeline
- **Jenkins UI**: Ver logs en tiempo real
- **Docker Logs**: `docker-compose logs -f jenkins`
- **Archivos de Log**: `/var/jenkins_home/workspace/`

#### Reportes Generados
- **Checkov Results**: `results.xml`
- **Terraform Outputs**: `outputs_[environment].txt`
- **Deploy Reports**: `deploy_report_[environment]_[timestamp].txt`

### Troubleshooting

#### Problemas Comunes

1. **Jenkins no inicia:**
   ```bash
   ./start-pipeline.sh restart
   ```

2. **Plugins no se instalan:**
   - Verificar archivo `plugins.txt`
   - Revisar logs de construcción
   - Limpiar caché de Docker

3. **Agente no se conecta:**
   - Verificar red Docker
   - Revisar logs del agente
   - Verificar configuración JNLP

4. **Checkov no funciona:**
   - Verificar que el agente esté corriendo
   - Revisar instalación con pipx
   - Verificar PATH de Python

5. **Credenciales AWS no válidas:**
   - Verificar variables de entorno
   - Revisar configuración en Jenkins

6. **Terraform init falla:**
   - Verificar permisos de AWS
   - Revisar configuración de backend

### Documentación Completa

Para información detallada sobre el pipeline, consultar:
- [Documentación de Jenkins](jenkins/README.md)
- [Documentación del Agente](agent-terraform/README.md)
- [Scripts de Automatización](jenkins/scripts/)
- [Configuración de Jenkins](jenkins/jobs/)

### Referencias

Este pipeline está basado en la configuración oficial de MovieSphere:
- [Repositorio Jenkins Setup](https://github.com/MovieSphere/jenkins-setup/tree/main)
- [Arquitectura de Agentes](https://github.com/MovieSphere/jenkins-setup/tree/main/agent-terraform)
- [Configuración de Jenkins](https://github.com/MovieSphere/jenkins-setup/tree/main/jenkins)

Este pipeline proporciona una solución completa y robusta para la automatización de infraestructura con Terraform, siguiendo las mejores prácticas de DevOps y seguridad, y manteniendo compatibilidad con la arquitectura establecida por MovieSphere.
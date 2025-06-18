# Jenkins Agent para Terraform

Este directorio contiene la configuración del agente de Jenkins especializado para operaciones de Terraform, siguiendo el patrón del repositorio de MovieSphere.

## 🏗️ Arquitectura del Agente

### Características

- **Base**: Ubuntu 22.04
- **Herramientas**: Terraform, Checkov, AWS CLI, Java 11
- **Usuario**: jenkins
- **Directorio de trabajo**: `/home/jenkins/workspace`

### Herramientas Instaladas

- **Terraform**: Última versión estable
- **Checkov**: Análisis de seguridad de infraestructura (instalado con pipx)
- **AWS CLI**: Gestión de recursos AWS
- **Java 11**: Requerido para Jenkins agent
- **Git**: Control de versiones
- **Python3**: Para herramientas adicionales

## 🚀 Configuración

### Variables de Entorno

```bash
AWS_DEFAULT_REGION=us-east-1
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
PATH=$PATH:$JAVA_HOME/bin:/root/.local/bin
```

### Volúmenes Montados

- `./Terraform` → `/home/jenkins/workspace/Terraform`
- `./agent-terraform/scripts` → `/home/jenkins/scripts`
- `./results.xml` → `/home/jenkins/workspace/results.xml`

## 📋 Scripts Disponibles

### terraform-validate.sh

Script principal de validación que ejecuta:

1. **Verificación de herramientas**
2. **Terraform Format** (`terraform fmt`)
3. **Terraform Validate** (`terraform validate`)
4. **Checkov Security Scan** (`checkov`)
5. **Análisis de estructura**

**Uso:**
```bash
./scripts/terraform-validate.sh [environment]
```

## 🔧 Configuración de Jenkins

### Configuración del Agente

El archivo `agent-config.xml` define la configuración del agente en Jenkins:

- **Nombre**: terraform-agent
- **Descripción**: Jenkins agent for Terraform operations
- **Ejecutores**: 2
- **Labels**: terraform docker
- **Directorio remoto**: /home/jenkins/workspace

### Variables de Entorno del Agente

- `AWS_DEFAULT_REGION`: us-east-1
- `JAVA_HOME`: /usr/lib/jvm/java-11-openjdk-amd64
- `PATH`: Incluye Java y herramientas del sistema

## 🐳 Docker

### Construir la Imagen

```bash
docker build -t jenkins-agent-terraform .
```

### Ejecutar el Contenedor

```bash
docker run -d \
  --name jenkins-agent-terraform \
  --network jenkins-network \
  -v $(pwd)/Terraform:/home/jenkins/workspace/Terraform \
  -v $(pwd)/agent-terraform/scripts:/home/jenkins/scripts \
  jenkins-agent-terraform
```

## 🔍 Validación Local

### Probar el Agente

```bash
# Entrar al contenedor
docker exec -it jenkins-agent-terraform bash

# Ejecutar validación
cd /home/jenkins/workspace
./scripts/terraform-validate.sh develop
```

### Verificar Herramientas

```bash
# Verificar Terraform
terraform version

# Verificar Checkov
checkov --version

# Verificar AWS CLI
aws --version

# Verificar Java
java -version
```

## 🔒 Checkov Integration

### Ejecutar Checkov Manualmente

```bash
# Desde el host (Linux)
./run-checkov.sh

# Desde el host (Windows PowerShell)
.\run-checkov.ps1

# Desde dentro del agente
docker exec jenkins-agent-terraform checkov --directory /home/jenkins/workspace/Terraform
```

### Configuración de Checkov

El archivo `.checkov.yml` en la raíz del proyecto configura las reglas de seguridad:

```yaml
skip-check:
    - CKV2_AWS_5  # Los SG están asociados a través de módulos
```

## 📊 Integración con Pipeline

### Jenkinsfile

El pipeline usa este agente con la configuración:

```groovy
agent {
    docker {
        image 'jenkins-agent-terraform:latest'
        args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
}
```

### Etapas del Pipeline

1. **Preparación**: Configuración inicial
2. **Validación de Código** (Paralelo):
   - Terraform Format
   - Terraform Validate
   - Checkov Security Scan
3. **Análisis de Módulos**
4. **Plan de Infraestructura**
5. **Aprobación Manual** (Producción)
6. **Aplicar Cambios**
7. **Generar Outputs**

## 🔒 Seguridad

### Permisos

- Usuario `jenkins` con permisos limitados
- Acceso sudo configurado
- Variables de entorno seguras

### Checkov

- Análisis automático de seguridad
- Configuración personalizada en `.checkov.yml`
- Reportes en formato JUnit XML
- Integrado directamente en el agente

## 🐛 Troubleshooting

### Problemas Comunes

1. **Agente no se conecta:**
   - Verificar red Docker
   - Revisar logs del contenedor
   - Verificar configuración JNLP

2. **Terraform no funciona:**
   - Verificar instalación
   - Revisar permisos de archivos
   - Verificar credenciales AWS

3. **Checkov no funciona:**
   - Verificar instalación con pipx
   - Revisar PATH de Python
   - Verificar archivos de entrada

### Logs

```bash
# Ver logs del contenedor
docker logs jenkins-agent-terraform

# Ver logs de Jenkins
docker logs jenkins-master
```

## 📚 Recursos

- [Jenkins Agent Documentation](https://www.jenkins.io/doc/book/using/using-agents/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Checkov Documentation](https://www.checkov.io/)
- [Docker Documentation](https://docs.docker.com/)

## 🤝 Contribución

Para contribuir al agente:

1. Crear una rama feature
2. Implementar cambios
3. Probar localmente
4. Crear Pull Request
5. Revisar y aprobar 
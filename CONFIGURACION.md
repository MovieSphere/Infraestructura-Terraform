# 🔧 Configuración de Variables de Entorno

Este documento explica cómo configurar las variables de entorno para el pipeline de Jenkins de forma segura y automática.

## 🚀 Configuración Rápida

### 1. Configurar Variables de Entorno

```bash
# Opción 1: Usar el script automático
./start-pipeline.sh setup

# Opción 2: Manual
cp env.example .env
# Editar .env con tus credenciales
```

### 2. Levantar el Pipeline

```bash
./start-pipeline.sh start
```

## 📋 Variables de Entorno

### 🔐 Credenciales AWS

```bash
AWS_ACCESS_KEY_ID=your_aws_access_key_here
AWS_SECRET_ACCESS_KEY=your_aws_secret_key_here
AWS_DEFAULT_REGION=us-east-1
```

**Obtener credenciales AWS:**
1. Ve a AWS Console → IAM → Users
2. Crea un usuario con permisos para Terraform
3. Genera Access Keys
4. Copia las credenciales al archivo `.env`

### 🔑 Credenciales Git

```bash
GIT_USERNAME=your_git_username
GIT_PASSWORD=your_git_password_or_token
GIT_REPOSITORY_URL=https://github.com/tu-usuario/Infraestructura-Terraform.git
GIT_BRANCH=main
```

**Obtener credenciales Git:**
1. **Para GitHub**: Ve a Settings → Developer settings → Personal access tokens
2. **Para GitLab**: Ve a User Settings → Access Tokens
3. Genera un token con permisos de `repo`
4. Usa tu username y el token como password

### ⚙️ Configuración Jenkins

```bash
JENKINS_USER=admin
JENKINS_PASSWORD=admin123
JENKINS_URL=http://localhost:8080
```

### 🏗️ Configuración Terraform

```bash
TERRAFORM_VERSION=latest
TERRAFORM_BACKEND_BUCKET=your-terraform-state-bucket
TERRAFORM_BACKEND_KEY=terraform.tfstate
TERRAFORM_BACKEND_REGION=us-east-1
```

### 🔒 Configuración Checkov

```bash
CHECKOV_SKIP_CHECKS=CKV2_AWS_5
CHECKOV_OUTPUT_FORMAT=cli,junitxml
CHECKOV_OUTPUT_FILE=results.xml
```

## 🔒 Seguridad

### ✅ Buenas Prácticas

1. **Nunca commits el archivo `.env`**
   - Está incluido en `.gitignore`
   - Solo usa `env.example` para documentación

2. **Usa tokens en lugar de contraseñas**
   - GitHub/GitLab Personal Access Tokens
   - AWS IAM Access Keys con permisos mínimos

3. **Rota las credenciales regularmente**
   - Cambia tokens cada 90 días
   - Usa diferentes credenciales por ambiente

4. **Usa variables de entorno en producción**
   - No uses archivos `.env` en servidores
   - Usa sistemas de gestión de secretos

### ❌ Lo que NO hacer

- ❌ Commits del archivo `.env`
- ❌ Credenciales hardcodeadas en scripts
- ❌ Usar la misma credencial para todos los ambientes
- ❌ Compartir credenciales por chat/email

## 🛠️ Configuración por Ambiente

### Desarrollo

```bash
# .env para desarrollo
AWS_DEFAULT_REGION=us-east-1
DEFAULT_ENVIRONMENT=develop
SKIP_APPROVAL_DEFAULT=true
```

### Staging

```bash
# .env para staging
AWS_DEFAULT_REGION=us-east-1
DEFAULT_ENVIRONMENT=staging
SKIP_APPROVAL_DEFAULT=false
```

### Producción

```bash
# .env para producción
AWS_DEFAULT_REGION=us-east-1
DEFAULT_ENVIRONMENT=production
SKIP_APPROVAL_DEFAULT=false
```

## 🔍 Verificación

### Verificar Configuración

```bash
# Verificar que las variables se cargan correctamente
./start-pipeline.sh status

# Verificar credenciales AWS
docker exec jenkins-agent-terraform aws sts get-caller-identity

# Verificar credenciales Git
docker exec jenkins-agent-terraform git ls-remote ${GIT_REPOSITORY_URL}
```

### Logs de Configuración

```bash
# Ver logs de configuración de Jenkins
docker-compose logs jenkins | grep "Configurando"

# Ver variables de entorno del agente
docker exec jenkins-agent-terraform env | grep -E "(AWS|GIT|JENKINS)"
```

## 🐛 Troubleshooting

### Problemas Comunes

#### 1. Variables no se cargan

```bash
# Verificar que el archivo .env existe
ls -la .env

# Verificar sintaxis del archivo
cat .env | grep -v '^#' | grep -v '^$'

# Recargar variables
source .env
```

#### 2. Credenciales AWS no válidas

```bash
# Verificar credenciales
aws sts get-caller-identity

# Verificar permisos
aws iam get-user
```

#### 3. Credenciales Git no válidas

```bash
# Verificar acceso al repositorio
git ls-remote ${GIT_REPOSITORY_URL}

# Verificar token
curl -H "Authorization: token ${GIT_PASSWORD}" https://api.github.com/user
```

#### 4. Jenkins no reconoce credenciales

```bash
# Verificar que Jenkins se reinició
docker-compose restart jenkins

# Verificar logs de configuración
docker-compose logs jenkins | grep "Credenciales"
```

## 📚 Referencias

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Docker Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [Jenkins Credentials](https://www.jenkins.io/doc/book/using/using-credentials/)

## 🤝 Contribución

Para contribuir a la configuración:

1. Actualiza `env.example` con nuevas variables
2. Documenta los cambios en este archivo
3. Verifica que `.gitignore` incluya `.env`
4. Prueba la configuración localmente 
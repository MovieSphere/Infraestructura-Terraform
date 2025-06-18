#!/bin/bash

# Script de gestión del pipeline de Jenkins para Terraform
# Basado en el repositorio de MovieSphere

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Función para logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Función para verificar y configurar variables de entorno
setup_environment() {
    log_step "🔧 Verificando configuración de variables de entorno..."
    
    # Verificar si existe el archivo .env
    if [ ! -f ".env" ]; then
        log_warn "Archivo .env no encontrado"
        
        if [ -f "env.example" ]; then
            log_info "Copiando env.example como .env..."
            cp env.example .env
            log_warn "⚠️  IMPORTANTE: Edita el archivo .env con tus credenciales reales antes de continuar"
            log_info "   Variables que debes configurar:"
            log_info "   - AWS_ACCESS_KEY_ID"
            log_info "   - AWS_SECRET_ACCESS_KEY"
            log_info "   - GIT_USERNAME"
            log_info "   - GIT_PASSWORD"
            log_info "   - GIT_REPOSITORY_URL"
            echo ""
            read -p "¿Quieres continuar sin configurar las credenciales? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Edita el archivo .env y ejecuta el script nuevamente"
                exit 0
            fi
        else
            log_error "No se encontró env.example. Crea un archivo .env manualmente"
            exit 1
        fi
    fi
    
    # Cargar variables de entorno
    if [ -f ".env" ]; then
        log_info "Cargando variables de entorno desde .env..."
        export $(cat .env | grep -v '^#' | xargs)
    fi
    
    # Verificar variables críticas
    local missing_vars=()
    
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ "$AWS_ACCESS_KEY_ID" = "your_aws_access_key_here" ]; then
        missing_vars+=("AWS_ACCESS_KEY_ID")
    fi
    
    if [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ "$AWS_SECRET_ACCESS_KEY" = "your_aws_secret_key_here" ]; then
        missing_vars+=("AWS_SECRET_ACCESS_KEY")
    fi
    
    if [ -z "$GIT_USERNAME" ] || [ "$GIT_USERNAME" = "your_git_username" ]; then
        missing_vars+=("GIT_USERNAME")
    fi
    
    if [ -z "$GIT_PASSWORD" ] || [ "$GIT_PASSWORD" = "your_git_password_or_token" ]; then
        missing_vars+=("GIT_PASSWORD")
    fi
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        log_warn "⚠️  Variables no configuradas: ${missing_vars[*]}"
        log_info "El pipeline funcionará con valores por defecto"
    else
        log_info "✅ Todas las variables críticas están configuradas"
    fi
}

# Función para mostrar ayuda
show_help() {
    echo "🚀 Script de gestión del pipeline de Jenkins para Terraform"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start     - Levantar todo el pipeline (Jenkins + Agent)"
    echo "  stop      - Parar todos los servicios"
    echo "  restart   - Reiniciar todos los servicios"
    echo "  status    - Mostrar estado de los servicios"
    echo "  logs      - Mostrar logs de Jenkins"
    echo "  build     - Reconstruir imágenes Docker"
    echo "  clean     - Limpiar todo (contenedores, volúmenes, imágenes)"
    echo "  validate  - Validar código Terraform localmente"
    echo "  checkov   - Ejecutar Checkov security scan"
    echo "  setup     - Configurar archivo .env"
    echo "  help      - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 setup          # Configurar variables de entorno"
    echo "  $0 start          # Levantar pipeline completo"
    echo "  $0 validate develop  # Validar ambiente develop"
    echo "  $0 checkov        # Ejecutar scan de seguridad"
    echo ""
    echo "📋 Configuración de Variables:"
    echo "  1. Copia env.example como .env"
    echo "  2. Edita .env con tus credenciales reales"
    echo "  3. Ejecuta $0 start"
}

# Función para configurar el archivo .env
setup_env_file() {
    log_step "🔧 Configurando archivo .env..."
    
    if [ ! -f "env.example" ]; then
        log_error "Archivo env.example no encontrado"
        exit 1
    fi
    
    if [ -f ".env" ]; then
        log_warn "Archivo .env ya existe"
        read -p "¿Quieres sobrescribirlo? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Operación cancelada"
            exit 0
        fi
    fi
    
    cp env.example .env
    log_info "✅ Archivo .env creado desde env.example"
    log_warn "⚠️  IMPORTANTE: Edita el archivo .env con tus credenciales reales"
    log_info "   Variables que debes configurar:"
    log_info "   - AWS_ACCESS_KEY_ID"
    log_info "   - AWS_SECRET_ACCESS_KEY"
    log_info "   - GIT_USERNAME"
    log_info "   - GIT_PASSWORD"
    log_info "   - GIT_REPOSITORY_URL"
}

# Función para levantar el pipeline
start_pipeline() {
    log_step "🚀 Iniciando pipeline completo de Jenkins..."
    
    # Verificar que Docker esté corriendo
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker no está corriendo. Inicia Docker Desktop primero."
        exit 1
    fi
    
    # Configurar variables de entorno
    setup_environment
    
    # Construir imágenes si no existen
    log_info "🔨 Construyendo imágenes Docker..."
    docker-compose build --no-cache
    
    # Levantar servicios
    log_info "📦 Levantando servicios..."
    docker-compose up -d
    
    # Esperar a que Jenkins esté listo
    log_info "⏳ Esperando a que Jenkins esté listo..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f http://localhost:8080/login > /dev/null 2>&1; then
            log_info "✅ Jenkins está listo!"
            break
        fi
        
        log_info "Intento $attempt/$max_attempts - Jenkins aún no está listo..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "❌ Jenkins no se inició en el tiempo esperado"
        log_info "Revisa los logs con: $0 logs"
        exit 1
    fi
    
    # Mostrar información de acceso
    show_access_info
}

# Función para mostrar información de acceso
show_access_info() {
    echo ""
    echo "🎉 Pipeline iniciado exitosamente!"
    echo ""
    echo "📋 Información de Acceso:"
    echo "   Jenkins URL: http://localhost:8080"
    echo "   Usuario: ${JENKINS_USER:-admin}"
    echo "   Contraseña: ${JENKINS_PASSWORD:-admin123}"
    echo ""
    echo "📋 Job Creado Automáticamente:"
    echo "   Nombre: ${PIPELINE_JOB_NAME:-terraform-pipeline}"
    echo "   URL: http://localhost:8080/job/${PIPELINE_JOB_NAME:-terraform-pipeline}"
    echo ""
    echo "📋 Configuración del Pipeline:"
    echo "   Repositorio: ${GIT_REPOSITORY_URL:-https://github.com/tu-usuario/Infraestructura-Terraform.git}"
    echo "   Rama: ${GIT_BRANCH:-main}"
    echo "   Ambiente por defecto: ${DEFAULT_ENVIRONMENT:-develop}"
    echo ""
    echo "⚠️  Próximos Pasos:"
    echo "   1. Accede a Jenkins en http://localhost:8080"
    echo "   2. Verifica que las credenciales se configuraron automáticamente"
    echo "   3. Ejecuta el pipeline con 'Build Now'"
    echo ""
    echo "🔧 Comandos Útiles:"
    echo "   Ver logs: $0 logs"
    echo "   Ver estado: $0 status"
    echo "   Reiniciar: $0 restart"
    echo "   Parar: $0 stop"
    echo ""
}

# Función para parar servicios
stop_pipeline() {
    log_step "🛑 Parando pipeline..."
    docker-compose down
    log_info "✅ Pipeline detenido"
}

# Función para reiniciar servicios
restart_pipeline() {
    log_step "🔄 Reiniciando pipeline..."
    docker-compose restart
    log_info "✅ Pipeline reiniciado"
}

# Función para mostrar estado
show_status() {
    log_step "📊 Estado de los servicios:"
    docker-compose ps
    echo ""
    
    # Verificar si Jenkins está respondiendo
    if curl -s -f http://localhost:8080/login > /dev/null 2>&1; then
        log_info "✅ Jenkins está corriendo y respondiendo"
    else
        log_warn "⚠️  Jenkins no está respondiendo"
    fi
    
    # Verificar agente
    if docker ps | grep -q "jenkins-agent-terraform"; then
        log_info "✅ Agente de Terraform está corriendo"
    else
        log_warn "⚠️  Agente de Terraform no está corriendo"
    fi
}

# Función para mostrar logs
show_logs() {
    log_step "📋 Mostrando logs de Jenkins:"
    docker-compose logs -f jenkins
}

# Función para reconstruir
build_images() {
    log_step "🔨 Reconstruyendo imágenes Docker..."
    docker-compose build --no-cache
    log_info "✅ Imágenes reconstruidas"
}

# Función para limpiar todo
clean_all() {
    log_step "🧹 Limpiando todo..."
    
    # Parar y remover contenedores
    docker-compose down -v
    
    # Remover imágenes
    docker rmi infraestructura-terraform-jenkins:latest infraestructura-terraform-agent-terraform:latest 2>/dev/null || true
    
    # Limpiar volúmenes no utilizados
    docker volume prune -f
    
    log_info "✅ Limpieza completada"
}

# Función para validar Terraform
validate_terraform() {
    local environment=${1:-"develop"}
    log_step "🔍 Validando código Terraform para ambiente: $environment"
    
    # Verificar que el agente esté corriendo
    if ! docker ps | grep -q "jenkins-agent-terraform"; then
        log_warn "Agente no está corriendo, iniciando..."
        docker-compose up -d agent-terraform
        sleep 10
    fi
    
    # Ejecutar validación
    docker exec jenkins-agent-terraform /home/jenkins/scripts/terraform-validate.sh "$environment"
}

# Función para ejecutar Checkov
run_checkov() {
    log_step "🔒 Ejecutando Checkov security scan..."
    
    # Verificar que el agente esté corriendo
    if ! docker ps | grep -q "jenkins-agent-terraform"; then
        log_warn "Agente no está corriendo, iniciando..."
        docker-compose up -d agent-terraform
        sleep 10
    fi
    
    # Ejecutar Checkov
    docker exec jenkins-agent-terraform checkov \
        --directory /home/jenkins/workspace/Terraform \
        -o cli \
        -o junitxml \
        --output-file-path /home/jenkins/workspace/results.xml
    
    log_info "✅ Checkov completado. Resultados en: results.xml"
}

# Función principal
main() {
    case "${1:-help}" in
        start)
            start_pipeline
            ;;
        stop)
            stop_pipeline
            ;;
        restart)
            restart_pipeline
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        build)
            build_images
            ;;
        clean)
            clean_all
            ;;
        validate)
            validate_terraform "$2"
            ;;
        checkov)
            run_checkov
            ;;
        setup)
            setup_env_file
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Comando desconocido: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@" 
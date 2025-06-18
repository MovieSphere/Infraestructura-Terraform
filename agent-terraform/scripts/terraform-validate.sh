#!/bin/bash

# Script de validación de Terraform para Jenkins Agent
# Basado en el repositorio de MovieSphere

set -e

echo "🔍 Iniciando validación de Terraform..."

# Variables
TERRAFORM_DIR="Terraform"
ENVIRONMENT=${1:-"develop"}
CHECKOV_CONFIG=".checkov.yml"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Verificar herramientas
check_tools() {
    log_info "Verificando herramientas instaladas..."
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform no está instalado"
        exit 1
    fi
    
    if ! command -v checkov &> /dev/null; then
        log_error "Checkov no está instalado"
        exit 1
    fi
    
    log_info "✅ Herramientas verificadas"
    log_info "Terraform version: $(terraform version)"
    log_info "Checkov version: $(checkov --version)"
}

# 1. Terraform Format
terraform_format() {
    log_info "🔧 Verificando formato de Terraform..."
    cd $TERRAFORM_DIR
    
    if terraform fmt -check -recursive; then
        log_info "✅ Formato de Terraform correcto"
    else
        log_error "❌ Formato de Terraform incorrecto"
        log_info "Aplicando formato automáticamente..."
        terraform fmt -recursive
        exit 1
    fi
}

# 2. Terraform Validate
terraform_validate() {
    log_info "✅ Ejecutando terraform validate..."
    cd $TERRAFORM_DIR
    
    for env in environments/*; do
        if [ -d "$env" ]; then
            env_name=$(basename "$env")
            log_info "Validando ambiente: $env_name"
            
            cd "$env"
            if terraform init -backend=false; then
                if terraform validate; then
                    log_info "✅ Ambiente $env_name validado correctamente"
                else
                    log_error "❌ Validación falló en ambiente $env_name"
                    exit 1
                fi
            else
                log_error "❌ No se pudo inicializar ambiente $env_name"
                exit 1
            fi
            cd - > /dev/null
        fi
    done
}

# 3. Checkov Security Scan
checkov_scan() {
    log_info "🔒 Ejecutando Checkov security scan..."
    cd $TERRAFORM_DIR
    
    mkdir -p results
    
    if [ -f "$CHECKOV_CONFIG" ]; then
        log_info "Usando configuración personalizada de Checkov"
        checkov -d . --config-file $CHECKOV_CONFIG --output cli --output junitxml --output-file-path ./results
    else
        log_info "Usando configuración por defecto de Checkov"
        checkov -d . --output cli --output junitxml --output-file-path ./results
    fi
    
    if [ $? -eq 0 ]; then
        log_info "✅ Scan de seguridad completado sin problemas críticos"
    else
        log_warn "⚠️  Se encontraron problemas de seguridad (revisar resultados)"
    fi
}

# 4. Análisis de estructura
analyze_structure() {
    log_info "📦 Analizando estructura del proyecto..."
    cd $TERRAFORM_DIR
    
    echo "Módulos encontrados:"
    find modules -name "*.tf" -type f | wc -l
    
    echo "Ambientes disponibles:"
    ls -la environments/
    
    echo "Archivos de configuración:"
    find . -name "*.tf" -type f | head -10
}

# Función principal
main() {
    log_info "🚀 Iniciando validación completa para ambiente: $ENVIRONMENT"
    
    check_tools
    terraform_format
    terraform_validate
    checkov_scan
    analyze_structure
    
    log_info "🎉 Validación completada exitosamente"
}

# Ejecutar función principal
main 
#!/bin/bash

# Script para validación completa de Terraform
# Incluye fmt, validate y checkov

set -e

echo "🔍 Iniciando validación completa de Terraform..."

# Variables
TERRAFORM_DIR="Terraform"
ENVIRONMENT=${1:-"develop"}
CHECKOV_CONFIG=".checkov.yml"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Verificar que Terraform esté instalado
if ! command -v terraform &> /dev/null; then
    log_error "Terraform no está instalado"
    exit 1
fi

# Verificar que Checkov esté instalado
if ! command -v checkov &> /dev/null; then
    log_warn "Checkov no está instalado, instalando..."
    pip install checkov
fi

# 1. Terraform Format Check
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

# 2. Terraform Validate
log_info "✅ Ejecutando terraform validate..."
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

# 3. Checkov Security Scan
log_info "🔒 Ejecutando Checkov security scan..."
cd $TERRAFORM_DIR

# Crear directorio para resultados si no existe
mkdir -p results

# Ejecutar Checkov con configuración personalizada
if [ -f "$CHECKOV_CONFIG" ]; then
    log_info "Usando configuración personalizada de Checkov"
    checkov -d . --config-file $CHECKOV_CONFIG --output cli --output junitxml --output-file-path ./results
else
    log_info "Usando configuración por defecto de Checkov"
    checkov -d . --output cli --output junitxml --output-file-path ./results
fi

# Verificar resultados de Checkov
if [ $? -eq 0 ]; then
    log_info "✅ Scan de seguridad completado sin problemas críticos"
else
    log_warn "⚠️  Se encontraron problemas de seguridad (revisar resultados)"
fi

# 4. Análisis de dependencias
log_info "📦 Analizando dependencias de módulos..."
echo "Módulos encontrados:"
find modules -name "*.tf" -type f | wc -l

echo "Ambientes disponibles:"
ls -la environments/

# 5. Verificación de variables
log_info "🔍 Verificando variables requeridas..."
for env in environments/*; do
    if [ -d "$env" ]; then
        env_name=$(basename "$env")
        log_info "Verificando variables en ambiente: $env_name"
        
        if [ -f "$env/variables.tf" ]; then
            echo "Variables definidas en $env_name:"
            grep -E "^variable" "$env/variables.tf" | wc -l
        else
            log_warn "No se encontró archivo variables.tf en $env_name"
        fi
    fi
done

log_info "🎉 Validación completa finalizada exitosamente" 
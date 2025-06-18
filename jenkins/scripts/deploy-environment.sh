#!/bin/bash

# Script para desplegar infraestructura en ambientes específicos
# Uso: ./deploy-environment.sh [environment] [action]

set -e

# Variables
ENVIRONMENT=${1:-"develop"}
ACTION=${2:-"plan"}
TERRAFORM_DIR="Terraform"
WORKSPACE_DIR="$TERRAFORM_DIR/environments/$ENVIRONMENT"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Verificar parámetros
if [ -z "$ENVIRONMENT" ]; then
    log_error "Debe especificar un ambiente"
    echo "Uso: $0 [environment] [action]"
    echo "Ambientes disponibles: develop, production"
    echo "Acciones disponibles: plan, apply, destroy"
    exit 1
fi

# Verificar que el ambiente existe
if [ ! -d "$WORKSPACE_DIR" ]; then
    log_error "El ambiente '$ENVIRONMENT' no existe"
    echo "Ambientes disponibles:"
    ls -la $TERRAFORM_DIR/environments/
    exit 1
fi

# Verificar credenciales de AWS
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    log_warn "Credenciales de AWS no configuradas"
    log_info "Asegúrate de configurar AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY"
fi

# Función para ejecutar Terraform
run_terraform() {
    local action=$1
    local workspace=$2
    
    log_step "Ejecutando terraform $action en ambiente $ENVIRONMENT"
    
    cd "$workspace"
    
    case $action in
        "init")
            log_info "Inicializando Terraform..."
            terraform init
            ;;
        "plan")
            log_info "Generando plan de Terraform..."
            terraform plan -out=tfplan
            ;;
        "apply")
            log_info "Aplicando cambios de Terraform..."
            if [ -f "tfplan" ]; then
                terraform apply -auto-approve tfplan
            else
                terraform apply -auto-approve
            fi
            ;;
        "destroy")
            log_warn "⚠️  DESTRUYENDO INFRAESTRUCTURA"
            read -p "¿Estás seguro de que quieres destruir el ambiente $ENVIRONMENT? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                terraform destroy -auto-approve
            else
                log_info "Operación cancelada"
                exit 0
            fi
            ;;
        "output")
            log_info "Generando outputs..."
            terraform output > outputs_${ENVIRONMENT}.txt
            ;;
        *)
            log_error "Acción '$action' no válida"
            exit 1
            ;;
    esac
    
    cd - > /dev/null
}

# Función para validar antes de aplicar
validate_before_apply() {
    if [ "$ACTION" = "apply" ] || [ "$ACTION" = "destroy" ]; then
        log_step "Validando configuración antes de $ACTION..."
        
        # Verificar que existe un plan válido
        if [ "$ACTION" = "apply" ] && [ ! -f "$WORKSPACE_DIR/tfplan" ]; then
            log_warn "No se encontró plan de Terraform, generando uno nuevo..."
            run_terraform "plan" "$WORKSPACE_DIR"
        fi
        
        # Verificar variables requeridas
        if [ -f "$WORKSPACE_DIR/variables.tf" ]; then
            log_info "Verificando variables requeridas..."
            # Aquí podrías agregar validaciones específicas de variables
        fi
    fi
}

# Función para limpiar archivos temporales
cleanup() {
    log_info "Limpiando archivos temporales..."
    find . -name "*.tfplan" -delete 2>/dev/null || true
    find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
}

# Función para generar reporte
generate_report() {
    local action=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    log_info "Generando reporte de despliegue..."
    
    cat > "deploy_report_${ENVIRONMENT}_$(date +%Y%m%d_%H%M%S).txt" << EOF
=== REPORTE DE DESPLIEGUE ===
Ambiente: $ENVIRONMENT
Acción: $action
Fecha: $timestamp
Usuario: $(whoami)
AWS Region: ${AWS_DEFAULT_REGION:-'No configurada'}

=== ESTADO DE LA INFRAESTRUCTURA ===
$(cd "$WORKSPACE_DIR" && terraform show 2>/dev/null || echo "No hay estado disponible")

=== OUTPUTS ===
$(cd "$WORKSPACE_DIR" && terraform output 2>/dev/null || echo "No hay outputs disponibles")
EOF
}

# Ejecución principal
main() {
    log_info "🚀 Iniciando despliegue en ambiente: $ENVIRONMENT"
    log_info "Acción a ejecutar: $ACTION"
    
    # Validar antes de aplicar
    validate_before_apply
    
    # Ejecutar acción de Terraform
    case $ACTION in
        "plan")
            run_terraform "init" "$WORKSPACE_DIR"
            run_terraform "plan" "$WORKSPACE_DIR"
            ;;
        "apply")
            run_terraform "init" "$WORKSPACE_DIR"
            run_terraform "plan" "$WORKSPACE_DIR"
            run_terraform "apply" "$WORKSPACE_DIR"
            run_terraform "output" "$WORKSPACE_DIR"
            generate_report "apply"
            ;;
        "destroy")
            run_terraform "init" "$WORKSPACE_DIR"
            run_terraform "destroy" "$WORKSPACE_DIR"
            generate_report "destroy"
            ;;
        "output")
            run_terraform "output" "$WORKSPACE_DIR"
            ;;
        *)
            log_error "Acción '$ACTION' no válida"
            echo "Acciones disponibles: plan, apply, destroy, output"
            exit 1
            ;;
    esac
    
    # Limpiar archivos temporales
    cleanup
    
    log_info "✅ Despliegue completado exitosamente"
}

# Ejecutar función principal
main 
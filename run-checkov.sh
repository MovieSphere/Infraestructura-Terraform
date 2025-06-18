#!/bin/bash

# Script para ejecutar Checkov usando el agente de Terraform
# Uso: ./run-checkov.sh [opciones]

set -e

# Variables por defecto
DIRECTORY=${1:-"Terraform"}
OUTPUT_FILE=${2:-"results.xml"}

echo "🔒 Ejecutando Checkov usando el agente de Terraform..."
echo "📁 Directorio: $DIRECTORY"
echo "📄 Archivo de salida: $OUTPUT_FILE"

# Verificar que el agente esté corriendo
if ! docker ps | grep -q "jenkins-agent-terraform"; then
    echo "⚠️  El agente de Terraform no está corriendo. Iniciando..."
    docker-compose up -d agent-terraform
    sleep 10
fi

# Ejecutar Checkov usando el agente de Terraform
docker exec jenkins-agent-terraform checkov \
  --directory /home/jenkins/workspace/$DIRECTORY \
  -o junitxml \
  --output-file-path /home/jenkins/workspace/$OUTPUT_FILE

echo "✅ Checkov completado exitosamente"
echo "📊 Resultados guardados en: $OUTPUT_FILE" 
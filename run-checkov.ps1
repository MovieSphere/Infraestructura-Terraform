# Script para ejecutar Checkov usando el agente de Terraform en Windows PowerShell
# Uso: .\run-checkov.ps1 [opciones]

param(
    [string]$Directory = "Terraform",
    [string]$OutputFile = "results.xml"
)

Write-Host "🔒 Ejecutando Checkov usando el agente de Terraform..." -ForegroundColor Green
Write-Host "📁 Directorio: $Directory" -ForegroundColor Yellow
Write-Host "📄 Archivo de salida: $OutputFile" -ForegroundColor Yellow

# Verificar que el agente esté corriendo
if (-not (docker ps | Select-String "jenkins-agent-terraform")) {
    Write-Host "⚠️  El agente de Terraform no está corriendo. Iniciando..." -ForegroundColor Yellow
    docker-compose up -d agent-terraform
    Start-Sleep -Seconds 10
}

# Ejecutar Checkov usando el agente de Terraform
docker exec jenkins-agent-terraform checkov `
  --directory /home/jenkins/workspace/$Directory `
  -o junitxml `
  --output-file-path /home/jenkins/workspace/$OutputFile

Write-Host "✅ Checkov completado exitosamente" -ForegroundColor Green
Write-Host "📊 Resultados guardados en: $OutputFile" -ForegroundColor Cyan 
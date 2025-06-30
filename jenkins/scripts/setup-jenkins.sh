#!/bin/bash

# Script de configuración automática de Jenkins
# Basado en el repositorio de MovieSphere

set -e

echo "🔧 Configurando Jenkins automáticamente..."

# Variables
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_PASS="admin123"
JOB_NAME="terraform-pipeline"
JOB_CONFIG_FILE="/tmp/job-config.xml"

# Función para esperar a que Jenkins esté listo
wait_for_jenkins() {
    echo "⏳ Esperando a que Jenkins esté listo..."
    while ! curl -s -f "$JENKINS_URL/login" > /dev/null; do
        echo "Jenkins no está listo aún, esperando..."
        sleep 10
    done
    echo "✅ Jenkins está listo!"
}

# Función para crear el job de pipeline
create_pipeline_job() {
    echo "📋 Creando job de pipeline: $JOB_NAME"
    
    # Crear configuración XML del job
    cat > "$JOB_CONFIG_FILE" << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@1300.vd2294d3341a_f">
  <description>Pipeline automatizado para infraestructura Terraform con validación completa</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <jenkins.model.BuildDiscarderProperty>
      <strategy class="hudson.tasks.LogRotator">
        <daysToKeep>30</daysToKeep>
        <numToKeep>10</numToKeep>
        <artifactDaysToKeep>-1</artifactDaysToKeep>
        <artifactNumToKeep>-1</artifactNumToKeep>
      </strategy>
    </jenkins.model.BuildDiscarderProperty>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.ChoiceParameterDefinition>
          <name>ENVIRONMENT</name>
          <description>Ambiente a desplegar</description>
          <choices class="java.util.Arrays$ArrayList">
            <a class="string-array">
              <string>develop</string>
              <string>staging</string>
              <string>production</string>
            </a>
          </choices>
        </hudson.model.ChoiceParameterDefinition>
        <hudson.model.BooleanParameterDefinition>
          <name>SKIP_APPROVAL</name>
          <description>Saltar aprobación manual (solo para develop/staging)</description>
          <defaultValue>false</defaultValue>
        </hudson.model.BooleanParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>TERRAFORM_VERSION</name>
          <description>Versión de Terraform a usar</description>
          <defaultValue>latest</defaultValue>
        </hudson.model.StringParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@3697.vb_470e4543b_ca_">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.15.0">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/tu-usuario/Infraestructura-Terraform.git</url>
          <credentialsId>git-credentials</credentialsId>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="empty-list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>false</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

    # Crear el job usando la API de Jenkins
    curl -X POST \
        -u "$JENKINS_USER:$JENKINS_PASS" \
        -H "Content-Type: application/xml" \
        --data-binary @"$JOB_CONFIG_FILE" \
        "$JENKINS_URL/createItem?name=$JOB_NAME"

    if [ $? -eq 0 ]; then
        echo "✅ Job '$JOB_NAME' creado exitosamente"
    else
        echo "❌ Error al crear el job '$JOB_NAME'"
        return 1
    fi
}

# Función para configurar credenciales básicas
setup_credentials() {
    echo "🔐 Configurando credenciales básicas..."
    
    # Crear credenciales para AWS (placeholder)
    cat > /tmp/aws-credentials.xml << 'EOF'
<com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl plugin="aws-credentials@1.0.8">
  <scope>GLOBAL</scope>
  <id>aws-credentials</id>
  <description>AWS Credentials for Terraform</description>
  <accessKey>YOUR_AWS_ACCESS_KEY</accessKey>
  <secretKey>YOUR_AWS_SECRET_KEY</secretKey>
  <iamRoleArn></iamRoleArn>
  <iamMfaSerialNumber></iamMfaSerialNumber>
</com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl>
EOF

    # Crear credenciales para Git (placeholder)
    cat > /tmp/git-credentials.xml << 'EOF'
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl plugin="credentials@1275.v54b_1c2c6388a_">
  <scope>GLOBAL</scope>
  <id>git-credentials</id>
  <description>Git Repository Credentials</description>
  <username>YOUR_GIT_USERNAME</username>
  <password>YOUR_GIT_PASSWORD_OR_TOKEN</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF

    echo "⚠️  Credenciales creadas como placeholders. Actualiza con valores reales en Jenkins UI."
}

# Función para configurar el agente de Terraform
setup_agent() {
    echo "🤖 Configurando agente de Terraform..."
    
    # Crear configuración del agente
    cat > /tmp/agent-config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<slave>
  <name>terraform-agent</name>
  <description>Jenkins agent for Terraform operations</description>
  <remoteFS>/home/jenkins/workspace</remoteFS>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>false</disabled>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
    <webSocket>false</webSocket>
  </launcher>
  <label>terraform docker</label>
  <nodeProperties>
    <hudson.slaves.EnvironmentVariablesNodeProperty>
      <envVars serialization="custom">
        <unserializable-parents/>
        <tree-map>
          <default>
            <comparator class="hudson.util.CaseInsensitiveComparator"/>
          </default>
          <int>2</int>
          <string>AWS_DEFAULT_REGION</string>
          <string>us-east-1</string>
          <string>JAVA_HOME</string>
          <string>/usr/lib/jvm/java-11-openjdk-amd64</string>
        </tree-map>
      </envVars>
    </hudson.slaves.EnvironmentVariablesNodeProperty>
  </nodeProperties>
  <userId>jenkins</userId>
</slave>
EOF

    echo "✅ Configuración del agente creada"
}

# Función para mostrar información de acceso
show_access_info() {
    echo ""
    echo "🎉 Jenkins configurado exitosamente!"
    echo ""
    echo "📋 Información de Acceso:"
    echo "   URL: $JENKINS_URL"
    echo "   Usuario: $JENKINS_USER"
    echo "   Contraseña: $JENKINS_PASS"
    echo ""
    echo "📋 Job Creado:"
    echo "   Nombre: $JOB_NAME"
    echo "   URL: $JENKINS_URL/job/$JOB_NAME"
    echo ""
    echo "⚠️  Próximos Pasos:"
    echo "   1. Accede a Jenkins en $JENKINS_URL"
    echo "   2. Configura las credenciales AWS y Git en 'Manage Jenkins' > 'Manage Credentials'"
    echo "   3. Actualiza la URL del repositorio Git en el job '$JOB_NAME'"
    echo "   4. Ejecuta el pipeline con 'Build Now'"
    echo ""
    echo "🔧 Comandos Útiles:"
    echo "   Ver logs: docker-compose logs -f jenkins"
    echo "   Reiniciar: docker-compose restart jenkins"
    echo "   Parar: docker-compose down"
    echo ""
}

# Función principal
main() {
    echo "🚀 Iniciando configuración automática de Jenkins..."
    
    # Esperar a que Jenkins esté listo
    wait_for_jenkins
    
    # Configurar credenciales básicas
    setup_credentials
    
    # Configurar agente
    setup_agent
    
    # Crear job de pipeline
    create_pipeline_job
    
    # Mostrar información de acceso
    show_access_info
    
    echo "✅ Configuración completada!"
}

# Ejecutar función principal
main 
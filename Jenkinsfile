pipeline {
    agent {
        docker {
            image 'jenkins-agent-terraform:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VERSION = '1.5.0'
        CHECKOV_VERSION = '2.3.0'
        ENVIRONMENTS = ['develop', 'production']
    }
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['develop', 'production', 'all'],
            description: 'Selecciona el ambiente a desplegar'
        )
        booleanParam(
            name: 'APPLY_CHANGES',
            defaultValue: false,
            description: '¿Aplicar cambios de Terraform? (Solo para producción)'
        )
        string(
            name: 'AWS_ACCESS_KEY_ID',
            defaultValue: '',
            description: 'AWS Access Key ID'
        )
        password(
            name: 'AWS_SECRET_ACCESS_KEY',
            defaultValue: '',
            description: 'AWS Secret Access Key'
        )
    }
    
    stages {
        stage('Preparación') {
            steps {
                script {
                    echo "🚀 Iniciando pipeline para ambiente: ${params.ENVIRONMENT}"
                    echo "📋 Parámetros configurados:"
                    echo "   - Ambiente: ${params.ENVIRONMENT}"
                    echo "   - Aplicar cambios: ${params.APPLY_CHANGES}"
                    
                    // Configurar credenciales de AWS
                    if (params.AWS_ACCESS_KEY_ID && params.AWS_SECRET_ACCESS_KEY) {
                        env.AWS_ACCESS_KEY_ID = params.AWS_ACCESS_KEY_ID
                        env.AWS_SECRET_ACCESS_KEY = params.AWS_SECRET_ACCESS_KEY
                        echo "✅ Credenciales de AWS configuradas"
                    } else {
                        echo "⚠️  Usando credenciales por defecto del sistema"
                    }
                }
            }
        }
        
        stage('Validación de Código') {
            parallel {
                stage('Terraform Format') {
                    steps {
                        script {
                            echo "🔧 Ejecutando terraform fmt..."
                            sh '''
                                cd Terraform
                                terraform fmt -check -recursive
                                if [ $? -eq 0 ]; then
                                    echo "✅ Formato de Terraform correcto"
                                else
                                    echo "❌ Formato de Terraform incorrecto"
                                    terraform fmt -recursive
                                    exit 1
                                fi
                            '''
                        }
                    }
                }
                
                stage('Terraform Validate') {
                    steps {
                        script {
                            echo "✅ Ejecutando terraform validate..."
                            sh '''
                                cd Terraform
                                terraform validate
                                if [ $? -eq 0 ]; then
                                    echo "✅ Validación de Terraform exitosa"
                                else
                                    echo "❌ Validación de Terraform falló"
                                    exit 1
                                fi
                            '''
                        }
                    }
                }
                
                stage('Checkov Security Scan') {
                    steps {
                        script {
                            echo "🔒 Ejecutando Checkov security scan..."
                            sh '''
                                cd Terraform
                                checkov -d . --output cli --output junitxml --output-file-path ./results
                                if [ $? -eq 0 ]; then
                                    echo "✅ Scan de seguridad completado"
                                else
                                    echo "⚠️  Se encontraron problemas de seguridad"
                                fi
                            '''
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: '**/results.xml'
                        }
                    }
                }
            }
        }
        
        stage('Análisis de Módulos') {
            steps {
                script {
                    echo "📦 Analizando módulos de Terraform..."
                    sh '''
                        cd Terraform
                        echo "Módulos encontrados:"
                        find modules -name "*.tf" -type f | head -10
                        echo ""
                        echo "Ambientes disponibles:"
                        ls -la environments/
                    '''
                }
            }
        }
        
        stage('Plan de Infraestructura') {
            when {
                anyOf {
                    expression { params.ENVIRONMENT == 'develop' }
                    expression { params.ENVIRONMENT == 'production' }
                }
            }
            steps {
                script {
                    def environments = params.ENVIRONMENT == 'all' ? ENVIRONMENTS : [params.ENVIRONMENT]
                    
                    environments.each { env ->
                        echo "📋 Generando plan para ambiente: ${env}"
                        dir("Terraform/environments/${env}") {
                            sh '''
                                terraform init
                                terraform plan -out=tfplan
                                echo "Plan generado exitosamente para ${env}"
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Aprobación Manual') {
            when {
                expression { params.ENVIRONMENT == 'production' && params.APPLY_CHANGES }
            }
            steps {
                script {
                    echo "⚠️  REQUIERE APROBACIÓN MANUAL"
                    echo "Se van a aplicar cambios en PRODUCCIÓN"
                    input message: '¿Confirmas aplicar los cambios en producción?', ok: 'Aplicar'
                }
            }
        }
        
        stage('Aplicar Cambios') {
            when {
                expression { 
                    (params.ENVIRONMENT == 'develop') || 
                    (params.ENVIRONMENT == 'production' && params.APPLY_CHANGES) 
                }
            }
            steps {
                script {
                    def environments = params.ENVIRONMENT == 'all' ? ENVIRONMENTS : [params.ENVIRONMENT]
                    
                    environments.each { env ->
                        echo "🚀 Aplicando cambios en ambiente: ${env}"
                        dir("Terraform/environments/${env}") {
                            sh '''
                                terraform apply -auto-approve tfplan
                                echo "Cambios aplicados exitosamente en ${env}"
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Generar Outputs') {
            when {
                expression { 
                    (params.ENVIRONMENT == 'develop') || 
                    (params.ENVIRONMENT == 'production' && params.APPLY_CHANGES) 
                }
            }
            steps {
                script {
                    def environments = params.ENVIRONMENT == 'all' ? ENVIRONMENTS : [params.ENVIRONMENT]
                    
                    environments.each { env ->
                        echo "📊 Generando outputs para ambiente: ${env}"
                        dir("Terraform/environments/${env}") {
                            sh '''
                                terraform output > outputs_${env}.txt
                                echo "Outputs generados para ${env}"
                            '''
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "🧹 Limpiando archivos temporales..."
                sh '''
                    find . -name "*.tfplan" -delete
                    find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
                '''
            }
        }
        
        success {
            script {
                echo "✅ Pipeline completado exitosamente"
                echo "📈 Resumen:"
                echo "   - Ambiente procesado: ${params.ENVIRONMENT}"
                echo "   - Cambios aplicados: ${params.APPLY_CHANGES}"
            }
        }
        
        failure {
            script {
                echo "❌ Pipeline falló"
                echo "🔍 Revisa los logs para más detalles"
            }
        }
        
        cleanup {
            script {
                echo "🧹 Limpieza final completada"
            }
        }
    }
} 
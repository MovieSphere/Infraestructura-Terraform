// Script de configuración automática de Jenkins
// Se ejecuta automáticamente al iniciar Jenkins
// Usa variables de entorno para configuración dinámica
import jenkins.model.*
import hudson.security.*
import hudson.slaves.*
import hudson.plugins.git.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import hudson.model.ParametersDefinitionProperty
import hudson.model.ChoiceParameterDefinition
import hudson.model.BooleanParameterDefinition
import hudson.model.StringParameterDefinition
import hudson.model.AllView
import hudson.tasks.LogRotator
import hudson.security.GlobalMatrixAuthorizationStrategy

println "🔧 Configurando Jenkins automáticamente..."

def instance = Jenkins.getInstance()

// Obtener variables de entorno
def env = System.getenv()
def jenkinsUser = env.get('JENKINS_USER') ?: 'admin'
def jenkinsPassword = env.get('JENKINS_PASSWORD') ?: 'admin123'
def gitUsername = env.get('GIT_USERNAME') ?: 'your_git_username'
def gitPassword = env.get('GIT_PASSWORD') ?: 'your_git_password_or_token'
def gitRepositoryUrl = env.get('GIT_REPOSITORY_URL') ?: 'https://github.com/tu-usuario/Infraestructura-Terraform.git'
def gitBranch = env.get('GIT_BRANCH') ?: 'main'
def awsAccessKey = env.get('AWS_ACCESS_KEY_ID') ?: 'your_aws_access_key'
def awsSecretKey = env.get('AWS_SECRET_ACCESS_KEY') ?: 'your_aws_secret_key'
def awsRegion = env.get('AWS_DEFAULT_REGION') ?: 'us-east-1'
def pipelineJobName = env.get('PIPELINE_JOB_NAME') ?: 'terraform-pipeline'
def defaultEnvironment = env.get('DEFAULT_ENVIRONMENT') ?: 'develop'

// 1. Configurar seguridad
println "🔐 Configurando seguridad..."
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(jenkinsUser, jenkinsPassword)
instance.setSecurityRealm(hudsonRealm)

// Configurar autorización
def strategy = new GlobalMatrixAuthorizationStrategy()
strategy.add(Jenkins.ADMINISTER, jenkinsUser)
strategy.add(Jenkins.READ, jenkinsUser)
strategy.add(Item.BUILD, jenkinsUser)
strategy.add(Item.READ, jenkinsUser)
strategy.add(Item.WRITE, jenkinsUser)
instance.setAuthorizationStrategy(strategy)

// 2. Configurar agente de Terraform
println "🤖 Configurando agente de Terraform..."
def agent = new DumbSlave(
    "terraform-agent",
    "Jenkins agent for Terraform operations",
    "/home/jenkins/workspace",
    "2",
    Node.Mode.NORMAL,
    "terraform docker",
    new JNLPLauncher(),
    new RetentionStrategy.Always(),
    new LinkedList()
)

// Agregar variables de entorno al agente
def envVars = new EnvironmentVariablesNodeProperty()
envVars.getEnvVars().put("AWS_DEFAULT_REGION", awsRegion)
envVars.getEnvVars().put("JAVA_HOME", "/usr/lib/jvm/java-11-openjdk-amd64")
envVars.getEnvVars().put("AWS_ACCESS_KEY_ID", awsAccessKey)
envVars.getEnvVars().put("AWS_SECRET_ACCESS_KEY", awsSecretKey)
agent.getNodeProperties().add(envVars)

instance.addNode(agent)

// 3. Crear job de pipeline
println "📋 Creando job de pipeline..."
def jobName = pipelineJobName

// Verificar si el job ya existe
if (instance.getItem(jobName) == null) {
    def job = new WorkflowJob(instance, jobName)
    job.setDescription("Pipeline automatizado para infraestructura Terraform con validación completa")
    
    // Configurar SCM (Git)
    def gitScm = new GitSCM([
        new UserRemoteConfig(
            gitRepositoryUrl,
            "git-credentials"
        )
    ])
    gitScm.setBranches([new BranchSpec("*/${gitBranch}")])
    
    // Configurar pipeline
    def flowDefinition = new CpsScmFlowDefinition(gitScm, "Jenkinsfile")
    job.setDefinition(flowDefinition)
    
    // Configurar parámetros
    def paramDefs = new ArrayList()
    
    // Parámetro de ambiente
    def envParam = new ChoiceParameterDefinition(
        "ENVIRONMENT",
        ["develop", "staging", "production"],
        "Ambiente a desplegar"
    )
    paramDefs.add(envParam)
    
    // Parámetro para saltar aprobación
    def skipParam = new BooleanParameterDefinition(
        "SKIP_APPROVAL",
        false,
        "Saltar aprobación manual (solo para develop/staging)"
    )
    paramDefs.add(skipParam)
    
    // Parámetro de versión de Terraform
    def versionParam = new StringParameterDefinition(
        "TERRAFORM_VERSION",
        "latest",
        "Versión de Terraform a usar"
    )
    paramDefs.add(versionParam)
    
    job.addProperty(new ParametersDefinitionProperty(paramDefs))
    
    // Configurar retención de builds
    job.setBuildDiscarder(new LogRotator(30, 10, -1, -1))
    
    instance.addView(new AllView(jobName))
    println "✅ Job '$jobName' creado exitosamente"
} else {
    println "ℹ️  Job '$jobName' ya existe"
}

// 4. Configurar credenciales básicas
println "🔐 Configurando credenciales básicas..."
def domain = Domain.global()
def store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

// Verificar si las credenciales ya existen
def existingCredentials = store.getCredentials(domain)
def awsCredsExist = existingCredentials.any { it.id == "aws-credentials" }
def gitCredsExist = existingCredentials.any { it.id == "git-credentials" }

if (!awsCredsExist) {
    // Crear credenciales AWS usando variables de entorno
    def awsCredentials = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        "aws-credentials",
        "AWS Credentials for Terraform",
        awsAccessKey,
        awsSecretKey
    )
    store.addCredentials(domain, awsCredentials)
    println "✅ Credenciales AWS creadas desde variables de entorno"
}

if (!gitCredsExist) {
    // Crear credenciales Git usando variables de entorno
    def gitCredentials = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        "git-credentials",
        "Git Repository Credentials",
        gitUsername,
        gitPassword
    )
    store.addCredentials(domain, gitCredentials)
    println "✅ Credenciales Git creadas desde variables de entorno"
}

// 5. Guardar configuración
instance.save()

println "🎉 Configuración de Jenkins completada!"
println ""
println "📋 Información de Acceso:"
println "   URL: http://localhost:8080"
println "   Usuario: ${jenkinsUser}"
println "   Contraseña: ${jenkinsPassword}"
println ""
println "📋 Configuración del Pipeline:"
println "   Job: ${jobName}"
println "   Repositorio: ${gitRepositoryUrl}"
println "   Rama: ${gitBranch}"
println "   Ambiente por defecto: ${defaultEnvironment}"
println ""
println "⚠️  Variables de Entorno Usadas:"
println "   AWS_ACCESS_KEY_ID: ${awsAccessKey != 'your_aws_access_key' ? 'Configurado' : 'Por configurar'}"
println "   GIT_USERNAME: ${gitUsername != 'your_git_username' ? 'Configurado' : 'Por configurar'}"
println "   GIT_REPOSITORY_URL: ${gitRepositoryUrl}"
println ""
if (awsAccessKey == 'your_aws_access_key' || gitUsername == 'your_git_username') {
    println "⚠️  IMPORTANTE: Configura las variables de entorno en el archivo .env"
    println "   Copia env.example como .env y actualiza los valores"
}
println "" 
# MovieSphere
## Problemática Identificada
Los usuarios de plataformas de streaming suelen tener dificultades para encontrar películas que realmente se ajusten a sus gustos. Muchas veces, las recomendaciones que reciben son genéricas y poco útiles, lo que hace que la búsqueda de una película interesante sea tediosa y frustrante. Por ello, muchas personas terminan recurriendo a páginas externas para leer opiniones o críticas antes de decidir qué ver. Ante esta situación, surge la necesidad de una plataforma como Moviesphere, que facilite a los usuarios descubrir películas de forma más rápida, personalizada y con una mejor experiencia.

## Resumen del Proyecto
Moviesphere es una plataforma web de recomendación de películas personalizada, similar a IMDb, que utiliza una arquitectura moderna basada en microservicios desplegados en contenedores Docker. La aplicación está desarrollada en Spring boot para el backend y TypeScript para el frontend (Angular), y utiliza PostgreSQL como base de datos principal para sus usuarios, entre otras. La infraestructura está definida con Terraform, permitiendo separar entornos de desarrollo, pruebas (staging) y producción. Este enfoque busca escalabilidad, facilidad de mantenimiento y automatización de despliegues con herramientas como Jenkins, Ansible y Terraform.


## 🏗️ Arquitectura

La infraestructura incluye:

- **VPC** con subredes públicas y privadas
- **EC2** para hosting de aplicaciones
- **Lambda** para funciones serverless
- **S3** para almacenamiento
- **CloudFront** para CDN
- **CloudWatch** para monitoreo básico

## 📋 Prerrequisitos

- AWS CLI configurado
- Terraform instalado
- Credenciales de AWS configuradas

## 🚀 Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/Infraestructura-Terraform.git
cd Infraestructura-Terraform
```

2. Inicializar Terraform:
```bash
cd Terraform
terraform init
```

3. Revisar el plan:
```bash
terraform plan
```

4. Aplicar la infraestructura:
```bash
terraform apply
```

## 🏢 Componentes

### VPC y Redes
- VPC con CIDR personalizable
- Subredes públicas y privadas
- Internet Gateway
- Tablas de rutas

### EC2
- Security Group con puertos 22 (SSH) y 80 (HTTP)
- Tags para identificación

### Lambda
- Función Python 3.9
- IAM Role con permisos mínimos
- Integración con CloudWatch Logs

### S3 y CloudFront
- Bucket S3 para frontend
- CloudFront como CDN
- Políticas de acceso seguras

### CloudWatch
- Monitoreo de EC2 (CPU)
- Logs de Lambda (7 días retención)
- Dashboard simple

## 💰 Costos

La infraestructura está diseñada para minimizar costos:
- Uso de servicios dentro del tier gratuito de AWS
- Monitoreo básico con CloudWatch
- Retención de logs reducida
- Sin VPC Endpoints costosos

## 🔒 Seguridad

- Security Groups con acceso mínimo
- IAM Roles con permisos específicos
- S3 con acceso público bloqueado
- CloudFront con HTTPS

## 📊 Monitoreo

CloudWatch Dashboard incluye:
- Métricas de CPU de EC2
- Invocaciones de Lambda
- Logs de Lambda

## 🧹 Limpieza

Para destruir la infraestructura:
```bash
terraform destroy
```
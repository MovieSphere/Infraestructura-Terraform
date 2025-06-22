module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  flow_logs_role_arn   = module.iam.vpc_flow_logs_role_arn
  aws_region           = var.region
}

module "security" {
  source       = "../../modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  user_ip_cidr = var.user_ip_cidr
  vpc_cidr     = var.vpc_cidr
}

module "cloudwatch" {
  source          = "../../modules/cloudwatch"
  project_name    = var.project_name
  region          = var.region
  ec2_instance_id = module.ec2.instance_id
  alarm_actions   = [module.logs.alerts_topic_arn] # Aqui se puede configurar el envio de SNS
}

module "api_gateway" {
  source          = "../../modules/api_gateway"
  project_name    = var.project_name
  integration_uri = module.alb.alb_dns_name
  kms_key_arn     = module.kms.kms_key_arn
}

module "rds" {
  source               = "../../modules/rds"
  project_name         = var.project_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_instance_class    = var.db_instance_class
  rds_sg_id            = module.security.rds_sg_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  monitoring_role_arn  = var.monitoring_role_arn
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

module "ec2" {
  source        = "../../modules/ec2"
  project_name  = var.project_name
  ami_id        = var.ami_id
  instance_type = var.instance_type
  private_id    = module.vpc.private_subnet_ids[0]
  ec2_sg_id     = module.security.ec2_sg_id
  key_name      = var.key_name

  auth_db_host    = module.rds.auth_db_address
  user_db_host    = module.rds.users_db_address
  catalog_db_host = module.rds.catalog_db_address

  db_username = var.db_username
  db_password = var.db_password

  iam_instance_profile = module.iam.aws_iam_instance_profile
  opensearch_endpoint = module.opensearch.opensearch_endpoint
}

module "alb" {
  # Valor temporal para avanzar. Reemplazar con ARN real del certificado HTTPS cuando esté disponible.
  acm_certificate_arn = "arn:aws:acm:us-east-1:000000000000:certificate/mock-certificate"
  source              = "../../modules/elb"
  project_name        = var.project_name
  alb_waf_arn         = module.waf.web_acl_arn
  alb_sg_id           = module.security.alb_sg_id
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  instance_ids        = [module.ec2.instance_id]
}

module "waf" {
  source              = "../../modules/waf"
  environment         = var.environment
  project_name        = var.project_name
  enable_waf_logging  = false //Por ahora, para pruebas
  waf_logs_bucket_arn = "arn:aws:s3:::mi-bucket-waf-logs" //Colocar aqui el arn del bucket para logs de waf
}

module "logs" {
  source          = "../../modules/logs"
  project_name    = var.project_name
  region          = var.region
  log_group_name  = "MyApp-${var.project_name}-Logs"
  alarm_email     = var.alarm_email
  ec2_instance_id = module.ec2.instance_id
}

module "s3" {
  source        = "../../modules/s3"
  project_name  = var.project_name
  environment   = var.environment
  bucket_suffix = var.bucket_suffix
  bucket_name   = "${var.project_name}-${var.environment}"
  kms_key_id    = module.kms.kms_key_arn
}

module "media" {
  source        = "../../modules/media"
  project_name  = var.project_name
  environment   = var.environment
  bucket_suffix = var.bucket_suffix
}

module "cloudfront" {
  source          = "../../modules/cloudfront"
  project_name    = var.project_name
  bucket_arn      = module.s3.bucket_arn
  bucket_name     = module.s3.bucket_name
  bucket_domain   = module.s3.bucket_domain
  cf_price_class  = var.cf_price_class
  cloudfront_web_acl_arn = module.waf.cloudfront_web_acl_arn
}

resource "aws_cloudwatch_log_group" "os_audit" {
  name              = "/os/${var.project_name}/audit-logs"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "os_index_slow" {
  name              = "/os/${var.project_name}/index-slow-logs"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "os_search_slow" {
  name              = "/os/${var.project_name}/search-slow-logs"
  retention_in_days = 365
}

module "opensearch" {
  source = "../../modules/opensearch"

  project_name               = var.project_name
  environment                = var.environment
  region                     = var.region
  domain_name                = var.project_name
  engine_version             = var.opensearch_engine_version
  instance_type              = var.opensearch_instance_type
  instance_count             = var.opensearch_instance_count
  opensearch_access_policies = module.iam.opensearch_access_policy_json

  # Encriptación y TLS
  kms_key_id                 = var.kms_key_id
  tls_security_policy        = var.tls_security_policy

  # VPC
  vpc_subnet_ids        = module.vpc.private_subnet_ids      # subredes privadas
  security_group_ids    = [module.security.ec2_sg_id]        # SGs adecuados
  vpc_id                = module.vpc.vpc_id

  # Logging (ARNs de CloudWatch Log Groups)
  audit_log_group_arn        = aws_cloudwatch_log_group.os_audit.arn
  index_slow_log_group_arn   = aws_cloudwatch_log_group.os_index_slow.arn
  search_slow_log_group_arn  = aws_cloudwatch_log_group.os_search_slow.arn
  opensearch_master_user_arn = "arn:aws:iam::512248046326:user/KathiaMR"

  tags = {
    Name        = "${var.project_name}-os-domain"
    Environment = var.environment
  }
}

module "kms" {
  source                  = "../../modules/kms"
  project_name            = var.project_name
  environment             = var.environment
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

module "acm" {
  source      = "../../modules/acm"
  project_name = var.project_name
  environment  = var.environment
  domain_name = var.domain_name
  zone_id     = var.zone_id
}


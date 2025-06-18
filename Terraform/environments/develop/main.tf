module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  aws_region           = var.region
  flow_logs_role_arn   = module.iam.flow_logs_role_arn
}

module "security" {
  source       = "../../modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  user_ip_cidr = var.user_ip_cidr
}

module "cloudwatch" {
  source           = "../../modules/cloudwatch"
  project_name     = var.project_name
  region           = var.region
  ec2_instance_id  = module.ec2.instance_id
  alarm_actions    = [module.monitoring.alerts_topic_arn] # Aqui se puede configurar el envio de SNS
}

module "api_gateway" {
  source          = "../../modules/api_gateway"
  project_name    = var.project_name
  integration_uri = module.alb.alb_dns_name
  kms_key_arn     = module.iam.kms_key_id
}

module "rds" {
  source               = "../../modules/rds"
  project_name         = var.project_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_instance_class    = var.db_instance_class
  rds_sg_id            = module.security.rds_sg_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  monitoring_role_arn  = module.iam.rds_monitoring_role_arn
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

  auth_db_host = module.rds.auth_db_address
  user_db_host = module.rds.users_db_address
  db_username  = var.db_username
  db_password  = var.db_password

  iam_instance_profile = module.iam.aws_iam_instance_profile
}

module "alb" {
  source            = "../../modules/elb"
  project_name      = var.project_name
  alb_sg_id         = module.security.alb_sg_id
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_ids      = [module.ec2.instance_id]
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
  bucket_name   = "${var.project_name}-${var.environment}-${var.bucket_suffix}"
  kms_key_id    = module.iam.kms_key_id
}

module "cloudfront" {
  source         = "../../modules/cloudfront"
  project_name   = var.project_name
  bucket_arn     = module.s3.bucket_arn
  bucket_name    = module.s3.bucket_name
  bucket_domain  = module.s3.bucket_domain
  cf_price_class = var.cf_price_class
}

module "opensearch" {
  source = "../../modules/opensearch"
  region = var.region
}
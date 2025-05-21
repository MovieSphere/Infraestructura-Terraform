module "vpc" {
  source              = "../../modules/vpc"
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
}

module "security" {
  source         = "../../modules/security"
  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  user_ip_cidr   = var.user_ip_cidr
}

module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  rds_sg_id             = module.security.rds_sg_id
  db_subnet_group_name  = module.vpc.db_subnet_group_name
}

module "ec2" {
  source          = "../../modules/ec2"
  project_name    = var.project_name
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  private_id      = module.vpc.private_subnet_id
  ec2_sg_id       = module.security.ec2_sg_id
  key_name        = var.key_name

  auth_db_host    = module.rds.auth_db_address
  user_db_host    = module.rds.users_db_address
  db_username     = var.db_username
  db_password     = var.db_password
}
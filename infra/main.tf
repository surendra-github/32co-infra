locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"
  
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
  tags               = local.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"
  
  vpc_id              = module.networking.vpc_id
  app_port            = var.app_port
  environment         = var.environment
  project_name        = var.project_name
  tags                = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"
  
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.private_subnet_ids
  security_group_id     = module.security.rds_security_group_id
  db_instance_class     = var.db_instance_class
  db_name               = var.db_name
  db_username           = var.db_username
  environment           = var.environment
  project_name          = var.project_name
  tags                  = local.common_tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  environment    = var.environment
  project_name   = var.project_name
  tags           = local.common_tags
}

# Compute Module
module "compute" {
  source = "./modules/compute"
  
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  ecs_security_group_id = module.security.ecs_security_group_id
  ecs_execution_role_arn = module.security.ecs_execution_role_arn
  ecs_task_role_arn     = module.security.ecs_task_role_arn
  ecs_task_role_name    = module.security.ecs_task_role_name
  ecs_execution_role_name = module.security.ecs_execution_role_name
  container_image       = var.container_image
  app_port              = var.app_port
  s3_bucket_arn         = module.storage.s3_bucket_arn
  database_endpoint     = module.database.db_endpoint
  database_name         = var.db_name
  database_username     = var.db_username
  database_password_arn = module.database.db_password_secret_arn
  environment           = var.environment
  project_name          = var.project_name
  tags                  = local.common_tags
}
# Get current AWS account ID
data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
  container_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-${var.environment}-webapp:latest"
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
  
  vpc_id       = module.networking.vpc_id
  app_port     = var.app_port
  environment  = var.environment
  project_name = var.project_name
  tags         = local.common_tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  environment  = var.environment
  project_name = var.project_name
  tags         = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"
  
  environment  = var.environment
  project_name = var.project_name
  aws_region   = var.aws_region
  tags         = local.common_tags
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.networking.vpc_id
  public_subnet_ids       = module.networking.public_subnet_ids
  private_subnet_ids      = module.networking.private_subnet_ids
  alb_security_group_id   = module.security.alb_security_group_id
  ecs_security_group_id   = module.security.ecs_security_group_id
  container_image         = local.container_image
  app_port                = var.app_port
  ecs_execution_role_arn  = module.security.ecs_execution_role_arn
  ecs_task_role_arn       = module.security.ecs_task_role_arn
  ecs_task_role_name      = module.security.ecs_task_role_name
  ecs_execution_role_name = module.security.ecs_execution_role_name
  dynamodb_table_arn      = module.database.dynamodb_table_arn
  dynamodb_table_name     = module.database.dynamodb_table_name
  app_secrets_arn         = module.security.app_secrets_arn
  s3_bucket_arn           = module.storage.s3_bucket_arn
  tags                    = local.common_tags
}

# Add after the compute module
module "monitoring" {
  source = "./modules/monitoring"
  
  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region
  alb_arn            = module.compute.alb_arn
  target_group_arn   = module.compute.target_group_arn
  ecs_cluster_name   = module.compute.ecs_cluster_name
  ecs_service_name   = module.compute.ecs_service_name
  dynamodb_table_name = module.database.dynamodb_table_name
  alert_email        = var.alert_email
  tags               = local.common_tags
}
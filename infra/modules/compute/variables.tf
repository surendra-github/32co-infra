variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of ECS execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  type        = string
}

variable "ecs_execution_role_name" {
  description = "Name of ECS execution role"
  type        = string
}

variable "ecs_task_role_name" {
  description = "Name of ECS task role"
  type        = string
}

variable "container_image" {
  description = "Docker image for the application"
  type        = string
}

variable "app_port" {
  description = "Application port"
  type        = number
}

variable "s3_bucket_arn" {
  description = "ARN of S3 bucket for static assets"
  type        = string
}

variable "database_endpoint" {
  description = "Database endpoint"
  type        = string
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "database_username" {
  description = "Database username"
  type        = string
}

variable "database_password_arn" {
  description = "ARN of database password secret"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}
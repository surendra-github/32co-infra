variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
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
  description = "ARN of the ECS execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "ecs_execution_role_name" {
  description = "Name of the ECS execution role"
  type        = string
}

variable "ecs_task_role_name" {
  description = "Name of the ECS task role"
  type        = string
}

variable "app_port" {
  description = "Port that the application listens on"
  type        = number
  default     = 8000
}

variable "container_image" {
  description = "Docker container image URI"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "app_secrets_arn" {
  description = "ARN of the application secrets"
  type        = string
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}

variable "enable_blue_green" {
  description = "Enable blue/green deployment with CodeDeploy"
  type        = bool
  default     = false
}
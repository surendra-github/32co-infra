variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "32co"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8000
}

variable "alert_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
  default     = ""
}

variable "enable_blue_green" {
  description = "Enable blue/green deployment strategy"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for ALB ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"] # or restrict as needed
}
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.compute.alb_dns_name
}

output "cloudfront_distribution_domain" {
  description = "Domain name of the CloudFront distribution"
  value       = module.storage.cloudfront_domain_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for static assets"
  value       = module.storage.s3_bucket_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.compute.ecs_cluster_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing Docker images"
  value       = module.compute.ecr_repository_url
}

output "monitoring_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.monitoring.dashboard_url
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = module.monitoring.sns_topic_arn
}
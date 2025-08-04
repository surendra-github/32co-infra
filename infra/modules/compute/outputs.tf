output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}
output "blue_target_group_name" {
  description = "Blue target group name"
  value       = aws_lb_target_group.main.name
}

output "green_target_group_name" {
  description = "Green target group name"
  value       = aws_lb_target_group.green.name
}

output "test_listener_arn" {
  description = "Test listener ARN"
  value       = aws_lb_listener.test.arn
}

output "alb_listener_arn" {
  description = "ARN of the main ALB listener"
  value       = aws_lb_listener.main.arn
}
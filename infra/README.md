# AWS Infrastructure as Code - DevOps Assessment

## Overview

This repository contains a complete Infrastructure as Code (IaC) solution for deploying a secure, scalable, and highly available web application infrastructure on AWS using Terraform.

## Architecture Components

### 🌐 Networking Components
- **VPC (Virtual Private Cloud)**: Custom VPC with CIDR block 10.0.0.0/16
- **Subnets**: 
  - Public subnets (2+) across multiple availability zones for ALB
  - Private subnets (2+) across multiple availability zones for application and database
- **Internet Gateway**: For public internet access
- **NAT Gateways**: One per AZ for secure outbound traffic from private subnets
- **Route Tables**: Separate route tables for public and private subnets
- **Elastic IPs**: For NAT Gateways

### 🔒 Security Components
- **Security Groups**:
  - ALB Security Group (ports 80, 443 from 0.0.0.0/0)
  - ECS Security Group (app port from ALB only)
- **IAM Roles**:
  - ECS Task Execution Role (with AmazonECSTaskExecutionRolePolicy)
  - ECS Task Role (with custom S3 and DynamoDB access policies)
- **AWS Secrets Manager**: For secure application secrets (e.g., API keys, DB passwords)
- **Encryption**: At-rest encryption for DynamoDB and S3

### 💻 Compute Resources
- **ECS Cluster**: Container orchestration platform
- **ECS Service**: Manages containerized application
- **ECS Task Definition**: Defines container specifications
- **Application Load Balancer (ALB)**: Distributes traffic across containers
- **Target Group**: Routes requests to healthy containers
- **Auto Scaling**: CPU-based scaling (70% threshold)
- **CloudWatch Logs**: Container logging

### 🗄️ Database Components
- **DynamoDB**: 
  - NoSQL database for persistent storage
  - Encryption at rest
  - Pay-per-request mode
- **Database Credentials**: Stored in AWS Secrets Manager (if needed for external DBs or APIs)

### 📦 Storage Components
- **S3 Bucket**: For static assets
  - Versioning enabled
  - Server-side encryption (AES256)
  - Public access blocked
- **CloudFront CDN**: Global content delivery
  - Origin Access Identity (OAI) for secure S3 access
  - HTTPS redirect enabled
  - Caching optimized for static content

### 📈 Monitoring Components
- **CloudWatch Log Groups**: Centralized logging for ECS containers
- **CloudWatch Metrics**: ECS service metrics, ALB metrics, DynamoDB metrics
- **CloudWatch Alarms**: Auto-scaling triggers, health checks, and alerting
- **Monitoring Module**: Modular Terraform code for log groups, metrics, and alarms

## Infrastructure Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                            Internet                              │
└────────────────────────────┬───────────────────────────────────┘
                             │
                    ┌────────┴────────┐
                    │ CloudFront CDN  │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │ Internet Gateway│
                    └────────┬────────┘
                             │
        ┌────────────────────┴───────────────────┐
        │                  VPC                   │
        │  ┌─────────────────────────────────┐   │
        │  │      Public Subnets (2+)        │   │
        │  │  ┌────────────────────────-─┐   │   │
        │  │  │ Application Load Balancer│   │   │
        │  │  └──────────┬──────────────-┘   │   │
        │  │             │                   │   │
        │  │      ┌──────┴──────┐            │   │
        │  │      │ NAT Gateway │            │   │
        │  └──────┴─────────────┴───────────-┘   │
        │                │                       │
        │  ┌─────────────┴──────────────────┐    │
        │  │      Private Subnets (2+)      │    │
        │  │  ┌───────────┐                 │    │
        │  │  │ECS Fargate│                 │    │
        │  │  │  Service  │                 │    │
        │  │  └───────────┘                 │    │
        │  │  ┌────────────┐                │    │
        │  │  │ DynamoDB   │                │    │
        │  │  └────────────┘                │    │
        │  └────────────────────────────────┘    │
        └────────────────────────────────────────┘
                             │
                    ┌────────┴────────┐
                    │   S3 Bucket     │
                    │ (Static Assets) │
                    └─────────────────┘
```

## Environment Configurations

### Development
- Single NAT Gateway (cost optimization)
- 1 ECS task
- No deletion protection

### Production
- NAT Gateway per AZ (high availability)
- 2+ ECS tasks with auto-scaling
- Deletion protection enabled

## Outputs

After deployment, Terraform will output:

- `alb_dns_name`: Load balancer URL for accessing the application
- `cloudfront_distribution_domain`: CDN URL for static assets
- `dynamodb_table_name`: Name of the DynamoDB table
- `s3_bucket_name`: Name of the S3 bucket
- `ecs_cluster_name`: Name of the ECS cluster
- `vpc_id`: ID of the created VPC
- `cloudwatch_log_group_name`: Name of the ECS log group
- `cloudwatch_alarm_arn`: ARN of critical CloudWatch alarms
- `alb_listener_arn`: ARN of the ALB listener for CodeDeploy
- `blue_target_group_arn`: ARN of the blue target group
- `green_target_group_arn`: ARN of the green target group

## Security Features

1. **Network Isolation**: Private subnets for application and database
2. **Least Privilege**: Security groups restrict traffic to minimum required
3. **Encryption**: 
   - DynamoDB encryption at rest
   - S3 server-side encryption
   - HTTPS enforcement via CloudFront
4. **Secrets Management**: Application secrets (e.g., API keys, DB passwords) in AWS Secrets Manager
5. **IAM Roles**: No hardcoded credentials, role-based access

## Secrets Management

- **AWS Secrets Manager** is used to securely store sensitive application secrets such as database passwords and external API keys.
- Secrets are injected into ECS containers as environment variables using the ECS task definition `secrets` block.
- IAM policies restrict access so only the ECS task can read the required secrets.

## Monitoring & Logging

- **CloudWatch Logs**: All container logs
- **Container Insights**: ECS cluster monitoring
- **CloudWatch Metrics**: Auto-scaling based on CPU utilization
- Monitoring resources are provisioned automatically via the monitoring module.


## Cost Optimization

- **Auto-scaling**: Scale down during low traffic
- **Fargate**: Pay only for resources used
- **S3 Lifecycle**: Can add policies for old object deletion
- **Spot Instances**: Can be configured for non-critical workloads

## Maintenance

### Updating Infrastructure
```bash
cd infra
terraform plan -var-file=environments/<env>/terraform.tfvars
terraform apply -var-file=environments/<env>/terraform.tfvars
```

### Deploying Application Updates
1. Build and push new Docker image
2. Update `container_image` variable
3. Run `terraform apply`

### Scaling
- ECS service scales automatically based on CPU/memory utilization (auto-scaling policies)
- Manual adjustment of desired count is possible if needed

## How to Enable Blue/Green Deployments

1. Set `enable_blue_green = true` in your environment's `terraform.tfvars`.
2. Deploy with Terraform as usual.
3. CodeDeploy will manage traffic shifting and rollback automatically.

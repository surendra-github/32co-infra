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
        ┌────────────────────┴────────────────────┐
        │                  VPC                     │
        │  ┌─────────────────────────────────┐   │
        │  │      Public Subnets (2+)        │   │
        │  │  ┌─────────────────────────┐   │   │
        │  │  │ Application Load Balancer│   │   │
        │  │  └──────────┬──────────────┘   │   │
        │  │             │                   │   │
        │  │      ┌──────┴──────┐           │   │
        │  │      │ NAT Gateway │           │   │
        │  └──────┴─────────────┴───────────┘   │
        │                │                        │
        │  ┌─────────────┴───────────────────┐   │
        │  │      Private Subnets (2+)       │   │
        │  │  ┌───────────┐                 │   │
        │  │  │ECS Fargate│                 │   │
        │  │  │  Service  │                 │   │
        │  │  └───────────┘                 │   │
        │  │  ┌────────────┐                │   │
        │  │  │ DynamoDB   │                │   │
        │  │  └────────────┘                │   │
        │  └─────────────────────────────────┘   │
        └─────────────────────────────────────────┘
                             │
                    ┌────────┴────────┐
                    │   S3 Bucket     │
                    │ (Static Assets) │
                    └─────────────────┘
```

## Directory Structure

```
.
├── infra/                    # Infrastructure as Code
│   ├── main.tf              # Root module configuration
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── versions.tf          # Provider versions
│   ├── modules/             # Reusable modules
│   │   ├── networking/      # VPC, subnets, gateways
│   │   ├── security/        # Security groups, IAM
│   │   ├── compute/         # ECS, ALB, auto-scaling
│   │   ├── database/        # DynamoDB
│   │   └── storage/         # S3, CloudFront
│   └── environments/        # Environment configurations
│       ├── dev/
│       ├── staging/
│       └── prod/
├── app/                     # Application code (optional)
└── README.md               # Project documentation
```

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0
3. **AWS CLI** configured with credentials
4. **Docker** (for building container images)
5. **S3 Bucket** for Terraform state (optional but recommended)

## Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd <repository-name>/infra
```

### 2. Configure AWS Credentials
```bash
aws configure
```

### 3. Initialize Terraform
```bash
cd infra
terraform init
```

### 4. Deploy Infrastructure
```bash
# Development environment
terraform workspace select dev
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars

# Production environment
terraform workspace select prod
terraform plan -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
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

**Example:**
```python
import os

db_password = os.environ.get("DB_PASSWORD")
api_key = os.environ.get("EXTERNAL_API_KEY")
```

**To update a secret:**
```bash
aws secretsmanager update-secret --secret-id "32co/prod/app/secrets" \
  --secret-string '{"DB_PASSWORD":"your-new-password","EXTERNAL_API_KEY":"your-new-api-key"}'
```

## Monitoring & Logging

- **CloudWatch Logs**: All container logs
- **Container Insights**: ECS cluster monitoring
- **CloudWatch Metrics**: Auto-scaling based on CPU utilization

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
- Modify `desired_count` in ECS service
- Adjust auto-scaling min/max capacity
- Update RDS instance class as needed

# 32co Infrastructure & Application Platform

A cloud-native application platform built with Infrastructure as Code (Terraform), containerized Python FastAPI application, and automated CI/CD pipeline.

## 🏗️ Architecture Overview

```
┌──────────────┐    ┌─────────────────┐
│     ALB      │────│  ECS Fargate    │
│   (HTTP)     │    │   (Containers)  │
└──────────────┘    └─────────────────┘
         │                     │
         │                     │
┌──────────────┐    ┌─────────────────┐
│  S3 Bucket   │    │   DynamoDB      │
│(Static Assets)│    │ (NoSQL Data)    │
└──────────────┘    └─────────────────┘
         │                     │
         └─────────┼───────────┘
                   │
      ┌──────────────┐
      │ VPC + Subnets│
      │ Public/Private│
      └──────────────┘
```

### Core Components
- **Networking**: VPC with public/private subnets across multiple AZs
- **Compute**: ECS Fargate with Application Load Balancer
- **Data**: DynamoDB for persistent storage
- **Storage**: S3 bucket for static assets
- **Security**: IAM roles, Security Groups, AWS Secrets Manager
- **Monitoring**: CloudWatch logs and metrics
- **CI/CD**: GitHub Actions with automated deployment

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Docker
- GitHub account

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/32co-infra.git
cd 32co-infra
```

### 2. Configure Variables
```bash
# Copy and customize terraform variables
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

Edit `infra/terraform.tfvars`:
```hcl
environment        = "prod"
aws_region         = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
app_port           = 8000
project_name       = "32co"
```

### 3. Deploy Infrastructure
```bash
cd infra

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy infrastructure
terraform apply
```

### 4. Setup CI/CD
Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `SNYK_TOKEN`: Snyk security scanning token (optional)
- `SLACK_WEBHOOK`: Slack notifications webhook (optional)

### 5. Deploy Application
```bash
# Push to main branch triggers automated deployment
git add .
git commit -m "Initial deployment"
git push origin main
```

## 🛠️ Tools & Technologies Used

### Infrastructure as Code
- **Terraform**: Infrastructure provisioning and management
- **AWS Provider**: Cloud resource management

### Application Stack
- **Python 3.9**: Runtime environment
- **FastAPI**: Modern web framework
- **Uvicorn**: ASGI server
- **Boto3**: AWS SDK for Python
- **Pytest**: Testing framework

### AWS Services
- **ECS Fargate**: Serverless container hosting
- **Application Load Balancer**: Traffic distribution with health checks
- **DynamoDB**: NoSQL database for persistent storage
- **S3**: Object storage for static assets
- **ECR**: Container registry
- **CloudWatch**: Logging and monitoring
- **Secrets Manager**: Secure credential storage and injection
- **VPC**: Network isolation and security

### CI/CD & DevOps
- **GitHub Actions**: Automated CI/CD pipeline
- **Docker**: Application containerization
- **Snyk**: Security vulnerability scanning

## 📋 Features Implemented

### Part 1: Infrastructure as Code ✅
- [x] Networking components (VPC, subnets, security groups)
- [x] Compute resources (ECS Fargate cluster)
- [x] Persistent data store (DynamoDB)
- [x] Object storage (S3)
- [x] IAM roles and security controls

### Part 2: CI/CD Pipeline ✅
- [x] Automated testing with pytest
- [x] Security scanning with Snyk
- [x] Docker image building and pushing
- [x] Automated deployment to ECS
- [x] Environment variable management

### Part 3: Application Secrets ✅
- [x] AWS Secrets Manager for sensitive data (database password, API keys)
- [x] Secure secret injection through ECS task definition secrets
- [x] IAM policies for least-privilege secret access
- [x] Automatic secret rotation capability (7-day recovery window)

## 🔧 API Endpoints

Once deployed, the application provides:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/`      | Welcome message |
| GET    | `/health` | Health check for load balancer |
| GET    | `/items` | List all items |
| POST   | `/items` | Create new item |
| GET    | `/items/{id}` | Get specific item |

### Example Usage
```bash
# Get application status
curl http://your-alb-dns/

# Health check
curl http://your-alb-dns/health

# Create an item
curl -X POST http://your-alb-dns/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Example Item", "description": "Test item", "category": "demo"}'

# Get all items
curl http://your-alb-dns/items
```

## 🔐 Secrets Management

### AWS Secrets Manager Integration
- **Database Password**: Auto-generated secure password stored in Secrets Manager
- **External API Key**: Configurable API key for external service integration
- **Secret Injection**: Secrets injected as environment variables in ECS containers
- **Access Control**: IAM policies restrict secret access to specific ECS tasks only

### Secret Configuration
```bash
# Update external API key after deployment
aws secretsmanager update-secret --secret-id "32co/prod/app/secrets" \
  --secret-string '{"DB_PASSWORD":"auto-generated","EXTERNAL_API_KEY":"your-actual-api-key"}'
```

### Application Usage
```python
# Secrets are available as environment variables in the container
db_password = os.environ.get("DB_PASSWORD")
api_key = os.environ.get("EXTERNAL_API_KEY")
```

## 🔐 Security Features

### Network Security
- Private subnets for application containers
- Security groups with least privilege access
- VPC isolation

### Application Security
- Container security scanning in CI/CD
- IAM roles for service authentication

### Data Security
- DynamoDB with proper IAM permissions
- S3 bucket with restricted access
- AWS Secrets Manager for sensitive credentials
- Encrypted secrets with automatic rotation capability

## 📊 Monitoring & Observability

### Logging
- Application logs via CloudWatch Logs
- ECS container logs with structured logging
- ALB access logs for request tracking

### Metrics
- ECS service CPU and memory utilization
- Application Load Balancer request metrics
- DynamoDB read/write metrics

## 🏗️ Project Structure

```
32co-infra/
├── app/                          # Python FastAPI application
│   ├── main.py                   # Application entry point
│   ├── requirements.txt          # Python dependencies
│   ├── Dockerfile               # Container definition
│   └── tests/                   # Unit tests
├── infra/                       # Terraform infrastructure
│   ├── main.tf                  # Root configuration
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   ├── versions.tf              # Provider versions
│   ├── terraform.tfvars         # Variable values
│   └── modules/                 # Reusable modules
│       ├── networking/          # VPC, subnets, gateways
│       ├── security/            # IAM, security groups
│       ├── compute/             # ECS, ALB
│       ├── database/            # DynamoDB
│       └── storage/             # S3
├── .github/workflows/           # CI/CD pipeline
│   └── ci-cd.yml               # GitHub Actions workflow
└── README.md                    # This file
```

## 🤔 Assumptions Made

### Infrastructure Assumptions
- **Single Region Deployment**: All resources deployed in us-east-1
- **Public Internet Access**: Application accessible from internet via HTTP
- **Managed Services**: Using AWS managed services for reduced operational overhead
- **Cost Optimization**: Using pay-per-request DynamoDB and Fargate for cost efficiency

### Application Assumptions
- **Stateless Design**: Application designed for horizontal scaling
- **RESTful API**: Standard REST patterns for item management
- **JSON Communication**: All API communication in JSON format
- **NoSQL Data Model**: Simple key-value structure suitable for DynamoDB

### Security Assumptions
- **AWS IAM**: Using AWS IAM for authentication and authorization
- **VPC Security**: Network-level security through VPC and security groups
- **HTTP Traffic**: Application serves HTTP traffic (no HTTPS implemented)

### Operational Assumptions
- **CloudWatch Monitoring**: AWS CloudWatch for logging and basic monitoring
- **Manual Scaling**: ECS service with fixed desired count (no auto-scaling)
- **Rolling Deployments**: Standard ECS deployment strategy

## ⚠️ Known Limitations

### Security Limitations
- **No HTTPS**: Application serves HTTP traffic only
- **Basic Security Groups**: Minimal security group configuration
- **No WAF**: No Web Application Firewall protection
- **Public ALB**: Application Load Balancer is internet-facing

### Scalability Limitations
- **No Auto Scaling**: Fixed number of ECS tasks
- **Single Region**: Not designed for multi-region deployments
- **No CDN**: No content delivery network for static assets

### Operational Limitations
- **Basic Monitoring**: Limited CloudWatch metrics and no alarms
- **No Backup Strategy**: No automated backup configuration
- **Manual Rollback**: No automated rollback mechanism

### Development Limitations
- **No Local Development**: No local development environment configuration
- **Basic CI/CD**: Simple deployment pipeline without advanced strategies
- **No Feature Flags**: No feature flag system implemented

## 🛠️ Troubleshooting

### Common Issues

#### ECS Service Won't Start
```bash
# Check ECS service events
aws ecs describe-services --cluster 32co-prod-cluster --services 32co-prod-service

# Check CloudWatch logs
aws logs tail /ecs/32co-prod-app --follow
```

#### Application Health Check Failing
```bash
# Test health endpoint directly
curl http://your-alb-dns/health

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...
```

#### DynamoDB Access Issues
```bash
# Verify IAM permissions
aws sts get-caller-identity

# Test DynamoDB access
aws dynamodb describe-table --table-name 32co-prod-items
```

### Useful Commands

```bash
# View Terraform state
terraform show

# Update ECS service
aws ecs update-service --cluster 32co-prod-cluster --service 32co-prod-service --force-new-deployment

# View application logs
aws logs tail /ecs/32co-prod-app --follow
```

## 🔄 Cleanup

To destroy all resources:

```bash
cd infra

# Destroy infrastructure (will prompt for confirmation)
terraform destroy

# Or auto-approve for automation
terraform destroy -auto-approve
```

**Note**: Some resources like S3 buckets may need to be emptied before destruction.

## 📝 Next Steps / Future Enhancements

### Security Improvements
- Implement HTTPS with SSL certificates
- Add Web Application Firewall (WAF)
- Restrict ALB to specific IP ranges
- Implement Secrets Manager for sensitive data

### Scalability Enhancements
- Add auto-scaling based on CPU/memory metrics
- Implement blue/green deployment strategy
- Add CloudFront CDN for static assets
- Multi-region deployment capability

### Operational Improvements
- Enhanced monitoring with CloudWatch alarms
- Automated backup strategies
- Log aggregation and analysis
- Performance optimization

## 🤔 Reflection

### Key Architectural Decisions Made

#### 1. **Chose DynamoDB over RDS for Data Storage**

**Decision**: Implemented DynamoDB as the persistent data store instead of a traditional SQL database like RDS.

**Why**: 
- The requirement stated "SQL or NoSQL" giving flexibility in choice
- DynamoDB offers better scalability with pay-per-request pricing
- Serverless nature aligns with the Fargate compute choice
- Simpler operational overhead (no patching, backups handled by AWS)
- Better integration with IAM for fine-grained access control

**Trade-offs Considered**:
- **Pro**: Auto-scaling, managed service, cost-effective for variable workloads
- **Con**: Less flexible querying compared to SQL, vendor lock-in
- **Alternative**: Could have used RDS with Aurora Serverless for SQL compatibility while maintaining serverless benefits

#### 2. **Implemented Auto-Scaling with Multiple Metrics**

**Decision**: Added ECS auto-scaling based on both CPU (70%) and Memory (80%) utilization with 2-10 task scaling range.

**Why**:
- Ensures application can handle traffic spikes automatically
- Multiple metrics prevent scaling on single resource bottlenecks
- Conservative thresholds (70/80%) provide buffer before performance degrades
- Min of 2 tasks ensures high availability even during low traffic

**Trade-offs Considered**:
- **Pro**: Automatic capacity management, cost optimization, improved availability
- **Con**: Slight complexity increase, potential for over-scaling in edge cases
- **Alternative**: Could have used fixed capacity or request-based scaling, but resource-based scaling is more predictable

#### 3. **Modular Terraform Architecture with Separation of Concerns**

**Decision**: Organized infrastructure into separate modules (networking, security, compute, database, storage) rather than a monolithic configuration.

**Why**:
- **Reusability**: Modules can be reused across environments (dev/staging/prod)
- **Maintainability**: Easier to update specific components without affecting others
- **Team Collaboration**: Different teams can own different modules
- **Testing**: Individual modules can be tested in isolation
- **Blast Radius**: Changes are contained within modules, reducing risk

**Trade-offs Considered**:
- **Pro**: Better organization, reusability, easier maintenance, reduced complexity per module
- **Con**: Initial setup complexity, potential over-engineering for simple use cases
- **Alternative**: Could have used a single main.tf file, but this doesn't scale well for real-world projects

### Additional Decisions Worth Noting

#### 4. **Container-First Architecture with ECS Fargate**
- Chose Fargate over EC2 for serverless container management
- Eliminates server management overhead but reduces control over underlying infrastructure
- Alternative: EKS would provide more Kubernetes ecosystem benefits but higher complexity

#### 5. **Secrets Management Strategy**
- Used AWS Secrets Manager for sensitive data (database passwords, API keys)
- ECS task definition injects secrets as environment variables at runtime
- IAM policies provide least-privilege access to specific secrets only
- Alternative: Could have used AWS Parameter Store for simpler configuration data

### Lessons Learned

1. **Start Simple, Scale Smart**: Began with core requirements and added features incrementally
2. **Embrace Managed Services**: Leveraged AWS managed services to reduce operational overhead
3. **Plan for Growth**: Modular architecture and auto-scaling prepare the infrastructure for future expansion
4. **Security by Design**: Implemented IAM roles, security groups, and VPC isolation from the start
5. **Operational Excellence**: Included logging, monitoring, and automated deployment from day one

These decisions balanced simplicity with production-readiness, ensuring the infrastructure can handle real-world requirements while remaining maintainable and cost-effective.

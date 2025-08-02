environment        = "prod"
aws_region         = "us-east-1"
vpc_cidr           = "10.1.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
db_instance_class  = "db.t3.small"
container_image    = "your-registry/webapp:latest"  # Replace with your app image
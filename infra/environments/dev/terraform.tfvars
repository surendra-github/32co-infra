environment        = "dev"
aws_region         = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
db_instance_class  = "db.t3.micro"
container_image    = "nginx:latest"  # Replace with your app image
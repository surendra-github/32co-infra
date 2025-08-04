resource "aws_dynamodb_table" "items" {
  name         = "${var.project_name}-${var.environment}-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = var.tags
}

# Create secrets for application configuration
resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${var.project_name}-${var.environment}-app-secrets"
  description = "Application secrets for ${var.project_name} ${var.environment}"

  tags = var.tags
}

# Store application secrets
resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    DYNAMODB_TABLE       = aws_dynamodb_table.items.name
    AWS_DEFAULT_REGION   = var.aws_region
    PYTHON_ENV           = var.environment
    EXTERNAL_API_KEY     = "your-external-api-key-here" # Replace with actual API key
    DB_CONNECTION_STRING = "dynamodb://${aws_dynamodb_table.items.name}"
  })
}
# Example S3 backend configuration
# Uncomment and configure after creating S3 bucket and DynamoDB table
# terraform {
#   backend "s3" {
#     bucket         = var.backend_bucket_name
#     key            = "${var.environment}/terraform.tfstate"
#     region         = var.aws_region
#     dynamodb_table = var.backend_dynamodb_table
#     encrypt        = true
#   }
# }

# To initialize with backend:
# terraform init -backend-config="bucket=your-terraform-state-bucket" \
#                -backend-config="key=dev/terraform.tfstate" \
#                -backend-config="region=us-east-1" \
#                -backend-config="dynamodb_table=terraform-state-lock"
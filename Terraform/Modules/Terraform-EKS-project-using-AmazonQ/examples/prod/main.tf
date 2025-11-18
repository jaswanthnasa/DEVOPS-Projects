terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  
  # Uncomment and configure after creating S3 bucket and DynamoDB table
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

module "eks_infrastructure" {
  source = "../../"
  
  # Basic configuration
  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name
  cluster_name = var.cluster_name
  
  # Network configuration
  vpc_cidr               = var.vpc_cidr
  az_count              = var.az_count
  enable_nat_gateway    = var.enable_nat_gateway
  single_nat_gateway    = var.single_nat_gateway
  enable_vpc_flow_logs  = var.enable_vpc_flow_logs
  
  # EKS configuration
  cluster_version                          = var.cluster_version
  cluster_endpoint_private_access          = var.cluster_endpoint_private_access
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  enable_cluster_logging                   = var.enable_cluster_logging
  cluster_log_types                        = var.cluster_log_types
  enable_fargate                           = var.enable_fargate
  
  # Node groups
  node_groups = var.node_groups
  
  # Addons
  addons = var.addons
  
  # KMS
  create_kms_key = var.create_kms_key
  kms_key_id     = var.kms_key_id
  
  # Tags
  tags = var.tags
}
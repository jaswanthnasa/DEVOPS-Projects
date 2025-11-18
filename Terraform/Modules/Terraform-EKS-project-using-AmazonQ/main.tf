locals {
  cluster_name = var.cluster_name != "" ? var.cluster_name : "${var.project_name}-${var.environment}"
  
  common_tags = merge(var.tags, {
    Environment = var.environment
    ClusterName = local.cluster_name
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# Provider configurations
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_ca_certificate)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_ca_certificate)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    }
  }
}

# KMS Key for EKS encryption
resource "aws_kms_key" "eks" {
  count = var.create_kms_key ? 1 : 0
  
  description             = "KMS key for EKS cluster ${local.cluster_name}"
  deletion_window_in_days = 7
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-kms-key"
  })
}

resource "aws_kms_alias" "eks" {
  count = var.create_kms_key ? 1 : 0
  
  name          = "alias/${local.cluster_name}-eks"
  target_key_id = aws_kms_key.eks[0].key_id
}

# Network module
module "network" {
  source = "./modules/network"
  
  vpc_cidr                = var.vpc_cidr
  availability_zones      = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, var.az_count)
  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway
  enable_vpc_flow_logs    = var.enable_vpc_flow_logs
  
  cluster_name = local.cluster_name
  tags         = local.common_tags
}

# IAM module
module "iam" {
  source = "./modules/iam"
  
  cluster_name    = local.cluster_name
  oidc_issuer_url = module.eks_cluster.oidc_issuer_url
  
  tags = local.common_tags
}

# EKS cluster module
module "eks_cluster" {
  source = "./modules/eks-cluster"
  
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id                               = module.network.vpc_id
  subnet_ids                          = module.network.private_subnet_ids
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  
  enable_cluster_logging = var.enable_cluster_logging
  cluster_log_types      = var.cluster_log_types
  
  kms_key_id = var.create_kms_key ? aws_kms_key.eks[0].arn : var.kms_key_id
  
  node_groups    = var.node_groups
  enable_fargate = var.enable_fargate
  
  cluster_service_role_arn = module.iam.cluster_service_role_arn
  node_group_role_arn      = module.iam.node_group_role_arn
  fargate_profile_role_arn = module.iam.fargate_profile_role_arn
  
  tags = local.common_tags
}

# Addons module
module "addons" {
  source = "./modules/addons"
  
  cluster_name     = local.cluster_name
  cluster_endpoint = module.eks_cluster.cluster_endpoint
  oidc_issuer_url  = module.eks_cluster.oidc_issuer_url
  
  addons = var.addons
  
  vpc_id = module.network.vpc_id
  
  # Service account roles from IAM module
  aws_load_balancer_controller_role_arn = module.iam.aws_load_balancer_controller_role_arn
  cluster_autoscaler_role_arn          = module.iam.cluster_autoscaler_role_arn
  ebs_csi_driver_role_arn              = module.iam.ebs_csi_driver_role_arn
  fluent_bit_role_arn                  = module.iam.fluent_bit_role_arn
  
  tags = local.common_tags
  
  depends_on = [module.eks_cluster]
}
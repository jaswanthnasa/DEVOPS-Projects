# Global Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "eks-cluster"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "eks-cluster"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Backend configuration variables
variable "backend_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = ""
}

variable "backend_dynamodb_table" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = ""
}

# Network variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = []
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway for all private subnets"
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

# EKS variables
variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks for public API access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_cluster_logging" {
  description = "Enable EKS cluster logging"
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "List of cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "enable_fargate" {
  description = "Enable Fargate profiles"
  type        = bool
  default     = false
}

# Node group variables
variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    instance_types = list(string)
    ami_type       = string
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    system = {
      instance_types = ["t3.medium"]
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      disk_size      = 20
      labels = {
        role = "system"
      }
      taints = []
    }
    workload = {
      instance_types = ["t3.large"]
      ami_type       = "AL2_x86_64"
      capacity_type  = "SPOT"
      min_size       = 0
      max_size       = 10
      desired_size   = 2
      disk_size      = 50
      labels = {
        role = "workload"
      }
      taints = []
    }
  }
}

# Addon variables
variable "addons" {
  description = "Map of addon configurations"
  type = map(object({
    enabled = bool
    version = string
    values  = map(any)
  }))
  default = {
    vpc_cni = {
      enabled = true
      version = "v1.15.1-eksbuild.1"
      values  = {}
    }
    kube_proxy = {
      enabled = true
      version = "v1.28.2-eksbuild.2"
      values  = {}
    }
    coredns = {
      enabled = true
      version = "v1.10.1-eksbuild.5"
      values  = {}
    }
    ebs_csi_driver = {
      enabled = true
      version = "v1.24.0-eksbuild.1"
      values  = {}
    }
    aws_load_balancer_controller = {
      enabled = true
      version = "1.6.2"
      values  = {}
    }
    cluster_autoscaler = {
      enabled = true
      version = "9.29.0"
      values  = {}
    }
    metrics_server = {
      enabled = true
      version = "3.11.0"
      values  = {}
    }
    fluent_bit = {
      enabled = true
      version = "0.46.7"
      values  = {}
    }
  }
}

# KMS variables
variable "create_kms_key" {
  description = "Create KMS key for EKS encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Existing KMS key ID for EKS encryption"
  type        = string
  default     = ""
}
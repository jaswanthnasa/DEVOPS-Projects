# Production Environment Configuration
aws_region   = "us-east-1"
environment  = "prod"
project_name = "eks-cluster"
cluster_name = "eks-cluster-prod"

# Network Configuration - Production sizing
vpc_cidr             = "10.1.0.0/16"
az_count            = 3
enable_nat_gateway  = true
single_nat_gateway  = false  # High availability for production
enable_vpc_flow_logs = true

# EKS Configuration
cluster_version                          = "1.28"
cluster_endpoint_private_access          = true
cluster_endpoint_public_access           = false  # Private only for production
cluster_endpoint_public_access_cidrs     = []
enable_cluster_logging                   = true
cluster_log_types                        = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
enable_fargate                           = true

# Node Groups - Production sizing
node_groups = {
  system = {
    instance_types = ["m5.large"]
    ami_type       = "AL2_x86_64"
    capacity_type  = "ON_DEMAND"
    min_size       = 3
    max_size       = 6
    desired_size   = 3
    disk_size      = 50
    labels = {
      role = "system"
    }
    taints = [{
      key    = "CriticalAddonsOnly"
      value  = "true"
      effect = "NO_SCHEDULE"
    }]
  }
  workload = {
    instance_types = ["m5.xlarge", "m5.2xlarge"]
    ami_type       = "AL2_x86_64"
    capacity_type  = "ON_DEMAND"
    min_size       = 2
    max_size       = 20
    desired_size   = 5
    disk_size      = 100
    labels = {
      role = "workload"
    }
    taints = []
  }
  spot_workload = {
    instance_types = ["m5.large", "m5.xlarge", "c5.large", "c5.xlarge"]
    ami_type       = "AL2_x86_64"
    capacity_type  = "SPOT"
    min_size       = 0
    max_size       = 50
    desired_size   = 3
    disk_size      = 100
    labels = {
      role = "spot-workload"
    }
    taints = [{
      key    = "spot"
      value  = "true"
      effect = "NO_SCHEDULE"
    }]
  }
}

# Addons Configuration
addons = {
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
    values = {
      "replicaCount" = "2"
      "resources.limits.cpu" = "200m"
      "resources.limits.memory" = "500Mi"
      "resources.requests.cpu" = "100m"
      "resources.requests.memory" = "200Mi"
    }
  }
  cluster_autoscaler = {
    enabled = true
    version = "9.29.0"
    values = {
      "replicaCount" = "2"
      "resources.limits.cpu" = "100m"
      "resources.limits.memory" = "300Mi"
      "resources.requests.cpu" = "100m"
      "resources.requests.memory" = "300Mi"
    }
  }
  metrics_server = {
    enabled = true
    version = "3.11.0"
    values = {
      "replicas" = "2"
    }
  }
  fluent_bit = {
    enabled = true
    version = "0.46.7"
    values = {
      "resources.limits.cpu" = "200m"
      "resources.limits.memory" = "200Mi"
      "resources.requests.cpu" = "100m"
      "resources.requests.memory" = "100Mi"
    }
  }
}

# Security
create_kms_key = true
kms_key_id     = ""

# Tags
tags = {
  Project     = "eks-cluster"
  Environment = "prod"
  ManagedBy   = "terraform"
  Team        = "platform"
  CostCenter  = "production"
  Owner       = "devops-team"
  Backup      = "required"
  Monitoring  = "critical"
}
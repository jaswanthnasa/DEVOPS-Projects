# Variables Reference

This document provides a comprehensive reference for all configurable variables in the EKS Terraform project.

## Global Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `"us-east-1"` | AWS region for resources |
| `environment` | string | `"dev"` | Environment name (dev, staging, prod) |
| `project_name` | string | `"eks-cluster"` | Project name for resource naming |
| `cluster_name` | string | `""` | EKS cluster name (auto-generated if empty) |
| `tags` | map(string) | See below | Common tags for all resources |

### Default Tags
```hcl
{
  Project     = "eks-cluster"
  Environment = "dev"
  ManagedBy   = "terraform"
}
```

## Backend Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `backend_bucket_name` | string | `""` | S3 bucket name for Terraform state |
| `backend_dynamodb_table` | string | `""` | DynamoDB table name for state locking |

## Network Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vpc_cidr` | string | `"10.0.0.0/16"` | CIDR block for VPC |
| `availability_zones` | list(string) | `[]` | List of availability zones (auto-detected if empty) |
| `az_count` | number | `3` | Number of availability zones to use |
| `enable_nat_gateway` | bool | `true` | Enable NAT Gateway for private subnets |
| `single_nat_gateway` | bool | `false` | Use single NAT gateway for all private subnets |
| `enable_vpc_flow_logs` | bool | `false` | Enable VPC Flow Logs |

## EKS Cluster Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cluster_version` | string | `"1.28"` | Kubernetes version for EKS cluster |
| `cluster_endpoint_private_access` | bool | `true` | Enable private API server endpoint |
| `cluster_endpoint_public_access` | bool | `true` | Enable public API server endpoint |
| `cluster_endpoint_public_access_cidrs` | list(string) | `["0.0.0.0/0"]` | CIDR blocks for public API access |
| `enable_cluster_logging` | bool | `true` | Enable EKS cluster logging |
| `cluster_log_types` | list(string) | See below | List of cluster log types to enable |
| `enable_fargate` | bool | `false` | Enable Fargate profiles |

### Default Cluster Log Types
```hcl
["api", "audit", "authenticator", "controllerManager", "scheduler"]
```

## Node Groups Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `node_groups` | map(object) | See below | Map of node group configurations |

### Node Group Object Structure
```hcl
{
  instance_types = list(string)  # EC2 instance types
  ami_type       = string        # AMI type (AL2_x86_64, AL2_ARM_64, etc.)
  capacity_type  = string        # ON_DEMAND or SPOT
  min_size       = number        # Minimum number of nodes
  max_size       = number        # Maximum number of nodes
  desired_size   = number        # Desired number of nodes
  disk_size      = number        # EBS volume size in GB
  labels         = map(string)   # Kubernetes labels
  taints = list(object({         # Kubernetes taints
    key    = string
    value  = string
    effect = string
  }))
}
```

### Default Node Groups
```hcl
{
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
```

## Addons Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `addons` | map(object) | See below | Map of addon configurations |

### Addon Object Structure
```hcl
{
  enabled = bool        # Whether to install the addon
  version = string      # Version to install
  values  = map(any)    # Additional configuration values
}
```

### Default Addons
```hcl
{
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
```

## KMS Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `create_kms_key` | bool | `true` | Create KMS key for EKS encryption |
| `kms_key_id` | string | `""` | Existing KMS key ID for EKS encryption |

## Environment-Specific Defaults

### Development Environment

| Variable | Dev Default | Reason |
|----------|-------------|---------|
| `single_nat_gateway` | `true` | Cost optimization |
| `enable_vpc_flow_logs` | `false` | Cost optimization |
| `cluster_endpoint_public_access` | `true` | Easy access for development |
| `enable_fargate` | `false` | Simpler setup |
| Node group instance types | `t3.medium`, `t3.large` | Cost-effective for dev workloads |
| Node group capacity | Smaller (1-5 nodes) | Minimal resource usage |

### Production Environment

| Variable | Prod Default | Reason |
|----------|--------------|---------|
| `single_nat_gateway` | `false` | High availability |
| `enable_vpc_flow_logs` | `true` | Security and compliance |
| `cluster_endpoint_public_access` | `false` | Enhanced security |
| `enable_fargate` | `true` | Serverless option for specific workloads |
| Node group instance types | `m5.large`, `m5.xlarge` | Better performance |
| Node group capacity | Larger (3-20 nodes) | Production workload capacity |

## Addon Version Compatibility

### EKS Version 1.28 Compatible Versions

| Addon | Version | Type |
|-------|---------|------|
| VPC CNI | `v1.15.1-eksbuild.1` | AWS Managed |
| kube-proxy | `v1.28.2-eksbuild.2` | AWS Managed |
| CoreDNS | `v1.10.1-eksbuild.5` | AWS Managed |
| EBS CSI Driver | `v1.24.0-eksbuild.1` | AWS Managed |
| AWS Load Balancer Controller | `1.6.2` | Helm |
| Cluster Autoscaler | `9.29.0` | Helm |
| Metrics Server | `3.11.0` | Helm |
| Fluent Bit | `0.46.7` | Helm |

## Instance Type Recommendations

### Development
- **System nodes**: `t3.medium` (2 vCPU, 4 GB RAM)
- **Workload nodes**: `t3.large` (2 vCPU, 8 GB RAM)

### Production
- **System nodes**: `m5.large` (2 vCPU, 8 GB RAM)
- **Workload nodes**: `m5.xlarge` or `m5.2xlarge` (4-8 vCPU, 16-32 GB RAM)
- **Spot workloads**: Mix of `m5.large`, `m5.xlarge`, `c5.large`, `c5.xlarge`

## Capacity Planning

### Node Group Sizing Guidelines

| Environment | Min Size | Max Size | Desired Size | Reasoning |
|-------------|----------|----------|--------------|-----------|
| **Dev System** | 1 | 3 | 2 | Minimal HA for system components |
| **Dev Workload** | 0 | 5 | 1 | Scale to zero when not needed |
| **Prod System** | 3 | 6 | 3 | Full HA across AZs |
| **Prod Workload** | 2 | 20 | 5 | Handle production traffic |
| **Prod Spot** | 0 | 50 | 3 | Burst capacity for cost optimization |

## Security Configuration Examples

### Development Security Settings
```hcl
cluster_endpoint_private_access = true
cluster_endpoint_public_access = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]  # Open for development
enable_vpc_flow_logs = false
create_kms_key = true
```

### Production Security Settings
```hcl
cluster_endpoint_private_access = true
cluster_endpoint_public_access = false  # Private only
cluster_endpoint_public_access_cidrs = []
enable_vpc_flow_logs = true
create_kms_key = true
```

## Cost Optimization Variables

### Development Cost Optimization
- `single_nat_gateway = true` (saves ~$45/month per NAT gateway)
- `enable_vpc_flow_logs = false` (saves CloudWatch costs)
- Smaller instance types and lower desired capacity
- Use SPOT instances for non-critical workloads

### Production Cost Optimization
- Use Cluster Autoscaler to scale down during low usage
- Mix ON_DEMAND and SPOT instances
- Use Reserved Instances for predictable workloads
- Enable detailed monitoring only where needed

## Validation Rules

### Required Variables
- `aws_region`: Must be a valid AWS region
- `environment`: Should match your deployment pipeline stages
- `vpc_cidr`: Must be a valid CIDR block (recommend /16 for flexibility)

### Recommended Constraints
- `cluster_name`: Should follow naming conventions (lowercase, hyphens)
- `az_count`: Should be 2 or 3 for production workloads
- Node group `min_size`: Should be >= 1 for system node groups
- Addon versions: Should be compatible with your EKS version

## Migration and Upgrade Considerations

### Upgrading EKS Version
1. Update `cluster_version`
2. Update compatible addon versions
3. Test in dev environment first
4. Plan maintenance window for production

### Changing Node Group Configuration
- Changing instance types requires node group replacement
- Scaling operations are non-disruptive
- Taint and label changes may require pod rescheduling

### Addon Version Updates
- AWS managed addons can be updated in-place
- Helm addons may require specific upgrade procedures
- Always check addon-specific upgrade documentation
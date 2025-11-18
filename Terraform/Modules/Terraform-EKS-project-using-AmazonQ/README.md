# EKS Terraform Infrastructure

A complete, production-ready Terraform project for deploying Amazon EKS clusters with managed node groups and essential add-ons.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                           AWS Account                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                        VPC (10.0.0.0/16)                   │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │ │
│  │  │   Public AZ-A   │  │   Public AZ-B   │  │ Public AZ-C  │ │ │
│  │  │  10.0.0.0/24    │  │  10.0.1.0/24    │  │ 10.0.2.0/24  │ │ │
│  │  │                 │  │                 │  │              │ │ │
│  │  │  ┌─────────────┐│  │  ┌─────────────┐│  │ ┌──────────┐ │ │ │
│  │  │  │ NAT Gateway ││  │  │ NAT Gateway ││  │ │NAT Gateway│ │ │ │
│  │  │  └─────────────┘│  │  └─────────────┘│  │ └──────────┘ │ │ │
│  │  └─────────────────┘  └─────────────────┘  └──────────────┘ │ │
│  │                                                             │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │ │
│  │  │  Private AZ-A   │  │  Private AZ-B   │  │ Private AZ-C │ │ │
│  │  │ 10.0.100.0/24   │  │ 10.0.101.0/24   │  │10.0.102.0/24 │ │ │
│  │  │                 │  │                 │  │              │ │ │
│  │  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │┌──────────┐  │ │ │
│  │  │ │EKS Nodes    │ │  │ │EKS Nodes    │ │  ││EKS Nodes │  │ │ │
│  │  │ │             │ │  │ │             │ │  ││          │  │ │ │
│  │  │ └─────────────┘ │  │ └─────────────┘ │  │└──────────┘  │ │ │
│  │  └─────────────────┘  └─────────────────┘  └──────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    EKS Control Plane                        │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │ │
│  │  │   API       │ │  Scheduler  │ │   Controller Manager    │ │ │
│  │  │   Server    │ │             │ │                         │ │ │
│  │  └─────────────┘ └─────────────┘ └─────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                        Add-ons                              │ │
│  │  • VPC CNI            • AWS Load Balancer Controller        │ │
│  │  • kube-proxy         • Cluster Autoscaler                 │ │
│  │  • CoreDNS            • Metrics Server                     │ │
│  │  • EBS CSI Driver     • Fluent Bit (Logging)              │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Features

- **Multi-AZ EKS Cluster**: Deployed across 3 availability zones for high availability
- **Managed Node Groups**: Auto-scaling worker nodes with launch templates
- **AWS Managed Add-ons**: VPC CNI, kube-proxy, CoreDNS, EBS CSI driver
- **Operational Add-ons**: AWS Load Balancer Controller, Cluster Autoscaler, Metrics Server, Fluent Bit
- **Security**: KMS encryption, IRSA, security groups, private endpoints
- **Networking**: VPC with public/private subnets, NAT gateways, flow logs
- **CI/CD**: GitHub Actions pipeline for automated deployments
- **Multi-Environment**: Separate configurations for dev and prod

## Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.5
- kubectl
- Helm (optional, for manual addon management)

### 1. Clone and Setup

```bash
git clone <repository-url>
cd terraform-s3-project
```

### 2. Configure Backend (Optional but Recommended)

Create S3 bucket and DynamoDB table for state management:

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://your-terraform-state-bucket

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

Then uncomment and configure the backend in `examples/dev/main.tf` and `examples/prod/main.tf`.

### 3. Deploy Development Environment

```bash
# Initialize Terraform
make dev-init

# Plan the deployment
make dev-plan

# Apply the changes
make dev-apply

# Get kubeconfig
make get-kubeconfig ENV=dev

# Verify cluster
make verify-cluster ENV=dev
```

### 4. Access Your Cluster

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-dev

# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -A

# Access sample application (if ALB controller is enabled)
kubectl get ingress -n sample-app
```

## Project Structure

```
├── README.md                    # This file
├── LICENSE                      # MIT License
├── CHANGELOG.md                 # Project changelog
├── Makefile                     # Common operations
├── versions.tf                  # Terraform version constraints
├── backend.tf                   # Backend configuration template
├── variables.tf                 # Global variables
├── main.tf                      # Root module configuration
├── outputs.tf                   # Root module outputs
├── terraform.tfvars.example     # Example variables file
├── .pre-commit-config.yaml      # Pre-commit hooks
├── modules/                     # Terraform modules
│   ├── network/                 # VPC, subnets, NAT gateways
│   ├── iam/                     # IAM roles and policies
│   ├── eks-cluster/             # EKS cluster and node groups
│   └── addons/                  # EKS addons and Helm releases
├── examples/                    # Environment-specific configurations
│   ├── dev/                     # Development environment
│   └── prod/                    # Production environment
├── scripts/                     # Helper scripts
│   └── get-kubeconfig.sh        # Kubeconfig management
└── .github/                     # GitHub Actions workflows
    └── workflows/
        └── terraform.yml        # CI/CD pipeline
```

## Module Documentation

### Network Module (`modules/network/`)

Creates VPC infrastructure with:
- VPC with configurable CIDR
- Public and private subnets across multiple AZs
- Internet Gateway and NAT Gateways
- Route tables and associations
- Optional VPC Flow Logs
- Security groups for EKS

### IAM Module (`modules/iam/`)

Creates IAM resources:
- EKS cluster service role
- Node group roles with required policies
- Fargate profile role
- IRSA roles for addons (ALB Controller, Cluster Autoscaler, etc.)
- OIDC identity provider

### EKS Cluster Module (`modules/eks-cluster/`)

Manages EKS cluster:
- EKS control plane with configurable settings
- Managed node groups with launch templates
- Security groups for cluster and nodes
- Optional Fargate profiles
- CloudWatch logging

### Addons Module (`modules/addons/`)

Installs and configures:
- **AWS Managed Addons**: VPC CNI, kube-proxy, CoreDNS, EBS CSI driver
- **Helm Addons**: AWS Load Balancer Controller, Cluster Autoscaler, Metrics Server, Fluent Bit
- Sample application with ALB ingress for testing

## Configuration

### Environment Variables

Key variables you can customize:

| Variable | Description | Default | Dev Example | Prod Example |
|----------|-------------|---------|-------------|--------------|
| `aws_region` | AWS region | `us-east-1` | `us-east-1` | `us-east-1` |
| `environment` | Environment name | `dev` | `dev` | `prod` |
| `cluster_name` | EKS cluster name | `""` | `eks-cluster-dev` | `eks-cluster-prod` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` | `10.0.0.0/16` | `10.1.0.0/16` |
| `single_nat_gateway` | Use single NAT | `false` | `true` | `false` |
| `cluster_endpoint_public_access` | Public API access | `true` | `true` | `false` |
| `enable_fargate` | Enable Fargate | `false` | `false` | `true` |

### Node Groups

Configure node groups in `terraform.tfvars`:

```hcl
node_groups = {
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

### Addons

Enable/disable and configure addon versions:

```hcl
addons = {
  vpc_cni = {
    enabled = true
    version = "v1.15.1-eksbuild.1"
    values  = {}
  }
  aws_load_balancer_controller = {
    enabled = true
    version = "1.6.2"
    values = {
      "replicaCount" = "2"
    }
  }
}
```

## Operations

### Common Commands

```bash
# Development environment
make dev-init          # Initialize dev environment
make dev-plan          # Plan dev changes
make dev-apply         # Apply dev changes
make dev-destroy       # Destroy dev environment

# Production environment
make prod-init         # Initialize prod environment
make prod-plan         # Plan prod changes
make prod-apply        # Apply prod changes
make prod-destroy      # Destroy prod environment

# Utilities
make fmt               # Format Terraform files
make validate          # Validate configuration
make get-kubeconfig    # Update kubeconfig
make verify-cluster    # Verify cluster functionality
```

### Upgrading Addons

To upgrade addon versions:

1. Update version in `terraform.tfvars`
2. Run `terraform plan` to see changes
3. Run `terraform apply` to upgrade

### Adding New Addons

1. Add addon configuration to `modules/addons/main.tf`
2. Add variables to `modules/addons/variables.tf`
3. Update default values in root `variables.tf`
4. Test in dev environment first

## Security Considerations

### Production Recommendations

- Set `cluster_endpoint_public_access = false`
- Use `single_nat_gateway = false` for high availability
- Enable VPC Flow Logs: `enable_vpc_flow_logs = true`
- Restrict `cluster_endpoint_public_access_cidrs` to your IP ranges
- Use dedicated KMS keys for encryption
- Enable all cluster log types
- Use ON_DEMAND instances for critical workloads

### IAM and RBAC

- All addon service accounts use IRSA (IAM Roles for Service Accounts)
- Least privilege IAM policies
- Node groups have minimal required permissions
- Consider implementing Kubernetes RBAC for application access

## Troubleshooting

### Common Issues

1. **Cluster creation fails**
   - Check IAM permissions
   - Verify subnet configuration
   - Ensure KMS key permissions

2. **Nodes not joining cluster**
   - Check security group rules
   - Verify node group IAM role
   - Check subnet routing

3. **Addons failing to install**
   - Verify IRSA configuration
   - Check Helm repository access
   - Review addon-specific logs

4. **ALB not creating**
   - Ensure AWS Load Balancer Controller is running
   - Check service account annotations
   - Verify subnet tags for load balancer discovery

### Debugging Commands

```bash
# Check cluster status
kubectl get nodes
kubectl get pods -A

# Check addon status
kubectl get pods -n kube-system
helm list -A

# Check AWS Load Balancer Controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Check Cluster Autoscaler
kubectl logs -n kube-system deployment/cluster-autoscaler
```

## Cost Optimization

### Development Environment

- Use `single_nat_gateway = true`
- Use SPOT instances for workload node groups
- Smaller instance types (`t3.medium`, `t3.large`)
- Disable VPC Flow Logs
- Lower node group desired capacity

### Production Environment

- Use multiple NAT gateways for HA
- Mix of ON_DEMAND and SPOT instances
- Larger instance types for better performance
- Enable comprehensive logging and monitoring
- Use Cluster Autoscaler for dynamic scaling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run pre-commit hooks: `pre-commit run --all-files`
5. Test in dev environment
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS EKS documentation
3. Open an issue in the repository

---

**Note**: The terms "EPC" and "QProxy" mentioned in requirements have been mapped to:
- **EPC** → **EBS CSI Driver** (AWS-maintained addon for persistent storage)
- **QProxy** → **kube-proxy** (AWS-maintained addon for network proxy)

If you intended different implementations, please modify the addon configurations in the `modules/addons/` directory.
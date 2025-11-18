# Changelog

All notable changes to this EKS Terraform project will be documented in this file.

## [1.0.0] - 2024-01-XX

### Added
- Complete EKS cluster infrastructure with Terraform
- Modular architecture with separate modules for:
  - Network (VPC, subnets, NAT gateways, security groups)
  - EKS Cluster (control plane, node groups, Fargate profiles)
  - IAM (roles and policies for cluster and addons)
  - Addons (managed addons and Helm releases)
- Support for multiple environments (dev/prod examples)
- AWS EKS managed addons:
  - VPC CNI plugin
  - kube-proxy
  - CoreDNS
  - EBS CSI driver
- Helm-based addons:
  - AWS Load Balancer Controller
  - Cluster Autoscaler
  - Metrics Server
  - Fluent Bit for logging
- Security features:
  - KMS encryption for EKS secrets
  - Security groups with least privilege
  - IRSA (IAM Roles for Service Accounts)
  - Optional VPC Flow Logs
- Automation and tooling:
  - GitHub Actions CI/CD pipeline
  - Makefile for common operations
  - Helper scripts for kubeconfig management
  - Pre-commit hooks for code quality
- Documentation:
  - Comprehensive README with architecture diagram
  - Variable reference table
  - Example configurations for dev and prod
  - Troubleshooting guide

### Features
- Multi-AZ deployment across 3 availability zones
- Managed node groups with autoscaling
- Optional Fargate profiles
- Sample application with ALB ingress
- Cost-optimized configurations for different environments
- Comprehensive logging and monitoring setup

### Security
- Encryption at rest for EBS volumes
- Private API endpoint option for production
- Least privilege IAM policies
- Security group rules following AWS best practices

### Notes
- EPC in the requirements has been mapped to EBS CSI driver (AWS-maintained addon)
- QProxy has been mapped to kube-proxy (AWS-maintained addon)
- All configurations are parameterized for easy customization
- Backend configuration is provided but commented out for initial setup
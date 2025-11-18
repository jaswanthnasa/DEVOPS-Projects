# Pass through outputs from the root module
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks_infrastructure.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_infrastructure.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks_infrastructure.cluster_security_group_id
}

output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = module.eks_infrastructure.vpc_id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.eks_infrastructure.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.eks_infrastructure.public_subnet_ids
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = module.eks_infrastructure.kubeconfig_command
}

output "node_groups" {
  description = "Map of node groups and their attributes"
  value       = module.eks_infrastructure.node_groups
}

output "installed_addons" {
  description = "List of installed addons"
  value       = module.eks_infrastructure.installed_addons
}
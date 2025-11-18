variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  type        = string
}

variable "oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  type        = string
}

variable "addons" {
  description = "Map of addon configurations"
  type = map(object({
    enabled = bool
    version = string
    values  = map(any)
  }))
  default = {}
}

variable "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller role"
  type        = string
}

variable "cluster_autoscaler_role_arn" {
  description = "ARN of the Cluster Autoscaler role"
  type        = string
}

variable "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI Driver role"
  type        = string
}

variable "fluent_bit_role_arn" {
  description = "ARN of the Fluent Bit role"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
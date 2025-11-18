output "cluster_service_role_arn" {
  description = "ARN of the EKS cluster service role"
  value       = aws_iam_role.cluster_service_role.arn
}

output "node_group_role_arn" {
  description = "ARN of the EKS node group role"
  value       = aws_iam_role.node_group_role.arn
}

output "fargate_profile_role_arn" {
  description = "ARN of the EKS Fargate profile role"
  value       = aws_iam_role.fargate_profile_role.arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller role"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the Cluster Autoscaler role"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI Driver role"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "fluent_bit_role_arn" {
  description = "ARN of the Fluent Bit role"
  value       = aws_iam_role.fluent_bit.arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}
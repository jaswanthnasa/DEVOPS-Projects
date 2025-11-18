output "installed_addons" {
  description = "List of installed addons"
  value = {
    vpc_cni = var.addons.vpc_cni.enabled ? {
      name    = "vpc-cni"
      version = var.addons.vpc_cni.version
      status  = var.addons.vpc_cni.enabled ? aws_eks_addon.vpc_cni[0].status : "disabled"
    } : null
    
    kube_proxy = var.addons.kube_proxy.enabled ? {
      name    = "kube-proxy"
      version = var.addons.kube_proxy.version
      status  = var.addons.kube_proxy.enabled ? aws_eks_addon.kube_proxy[0].status : "disabled"
    } : null
    
    coredns = var.addons.coredns.enabled ? {
      name    = "coredns"
      version = var.addons.coredns.version
      status  = var.addons.coredns.enabled ? aws_eks_addon.coredns[0].status : "disabled"
    } : null
    
    ebs_csi_driver = var.addons.ebs_csi_driver.enabled ? {
      name    = "aws-ebs-csi-driver"
      version = var.addons.ebs_csi_driver.version
      status  = var.addons.ebs_csi_driver.enabled ? aws_eks_addon.ebs_csi_driver[0].status : "disabled"
    } : null
    
    aws_load_balancer_controller = var.addons.aws_load_balancer_controller.enabled ? {
      name    = "aws-load-balancer-controller"
      version = var.addons.aws_load_balancer_controller.version
      status  = var.addons.aws_load_balancer_controller.enabled ? helm_release.aws_load_balancer_controller[0].status : "disabled"
    } : null
    
    cluster_autoscaler = var.addons.cluster_autoscaler.enabled ? {
      name    = "cluster-autoscaler"
      version = var.addons.cluster_autoscaler.version
      status  = var.addons.cluster_autoscaler.enabled ? helm_release.cluster_autoscaler[0].status : "disabled"
    } : null
    
    metrics_server = var.addons.metrics_server.enabled ? {
      name    = "metrics-server"
      version = var.addons.metrics_server.version
      status  = var.addons.metrics_server.enabled ? helm_release.metrics_server[0].status : "disabled"
    } : null
    
    fluent_bit = var.addons.fluent_bit.enabled ? {
      name    = "fluent-bit"
      version = var.addons.fluent_bit.version
      status  = var.addons.fluent_bit.enabled ? helm_release.fluent_bit[0].status : "disabled"
    } : null
  }
}

output "sample_app_ingress_hostname" {
  description = "Hostname of the sample application ALB"
  value = var.addons.aws_load_balancer_controller.enabled ? (
    length(kubernetes_ingress_v1.sample_nginx) > 0 ? 
    kubernetes_ingress_v1.sample_nginx[0].status[0].load_balancer[0].ingress[0].hostname : 
    null
  ) : null
}
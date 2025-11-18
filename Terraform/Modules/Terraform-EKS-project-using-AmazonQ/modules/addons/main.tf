# AWS EKS Managed Addons
resource "aws_eks_addon" "vpc_cni" {
  count = var.addons.vpc_cni.enabled ? 1 : 0
  
  cluster_name             = var.cluster_name
  addon_name               = "vpc-cni"
  addon_version            = var.addons.vpc_cni.version
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = null
  
  tags = var.tags
}

resource "aws_eks_addon" "kube_proxy" {
  count = var.addons.kube_proxy.enabled ? 1 : 0
  
  cluster_name      = var.cluster_name
  addon_name        = "kube-proxy"
  addon_version     = var.addons.kube_proxy.version
  resolve_conflicts = "OVERWRITE"
  
  tags = var.tags
}

resource "aws_eks_addon" "coredns" {
  count = var.addons.coredns.enabled ? 1 : 0
  
  cluster_name      = var.cluster_name
  addon_name        = "coredns"
  addon_version     = var.addons.coredns.version
  resolve_conflicts = "OVERWRITE"
  
  tags = var.tags
}

resource "aws_eks_addon" "ebs_csi_driver" {
  count = var.addons.ebs_csi_driver.enabled ? 1 : 0
  
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.addons.ebs_csi_driver.version
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = var.ebs_csi_driver_role_arn
  
  tags = var.tags
}

# Helm Releases for additional addons
resource "helm_release" "aws_load_balancer_controller" {
  count = var.addons.aws_load_balancer_controller.enabled ? 1 : 0
  
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.addons.aws_load_balancer_controller.version
  
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.aws_load_balancer_controller_role_arn
  }
  
  set {
    name  = "vpcId"
    value = var.vpc_id
  }
  
  set {
    name  = "region"
    value = data.aws_region.current.name
  }
  
  dynamic "set" {
    for_each = var.addons.aws_load_balancer_controller.values
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  count = var.addons.cluster_autoscaler.enabled ? 1 : 0
  
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = var.addons.cluster_autoscaler.version
  
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  
  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
  
  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.cluster_autoscaler_role_arn
  }
  
  set {
    name  = "extraArgs.scale-down-delay-after-add"
    value = "10m"
  }
  
  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "10m"
  }
  
  dynamic "set" {
    for_each = var.addons.cluster_autoscaler.values
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "metrics_server" {
  count = var.addons.metrics_server.enabled ? 1 : 0
  
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = var.addons.metrics_server.version
  
  set {
    name  = "args[0]"
    value = "--cert-dir=/tmp"
  }
  
  set {
    name  = "args[1]"
    value = "--secure-port=4443"
  }
  
  set {
    name  = "args[2]"
    value = "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
  }
  
  set {
    name  = "args[3]"
    value = "--kubelet-use-node-status-port"
  }
  
  dynamic "set" {
    for_each = var.addons.metrics_server.values
    content {
      name  = set.key
      value = set.value
    }
  }
}

# Create namespace for Fluent Bit
resource "kubernetes_namespace" "amazon_cloudwatch" {
  count = var.addons.fluent_bit.enabled ? 1 : 0
  
  metadata {
    name = "amazon-cloudwatch"
    
    labels = {
      name = "amazon-cloudwatch"
    }
  }
}

resource "helm_release" "fluent_bit" {
  count = var.addons.fluent_bit.enabled ? 1 : 0
  
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "amazon-cloudwatch"
  version    = var.addons.fluent_bit.version
  
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "fluent-bit"
  }
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.fluent_bit_role_arn
  }
  
  set {
    name  = "config.outputs"
    value = <<-EOT
      [OUTPUT]
          Name cloudwatch_logs
          Match *
          region ${data.aws_region.current.name}
          log_group_name /aws/eks/${var.cluster_name}/fluent-bit
          log_stream_prefix fluent-bit-
          auto_create_group true
    EOT
  }
  
  dynamic "set" {
    for_each = var.addons.fluent_bit.values
    content {
      name  = set.key
      value = set.value
    }
  }
  
  depends_on = [kubernetes_namespace.amazon_cloudwatch]
}

# Sample Ingress for testing ALB
resource "kubernetes_namespace" "sample_app" {
  count = var.addons.aws_load_balancer_controller.enabled ? 1 : 0
  
  metadata {
    name = "sample-app"
    
    labels = {
      name = "sample-app"
    }
  }
}

resource "kubernetes_deployment" "sample_nginx" {
  count = var.addons.aws_load_balancer_controller.enabled ? 1 : 0
  
  metadata {
    name      = "sample-nginx"
    namespace = "sample-app"
    
    labels = {
      app = "sample-nginx"
    }
  }
  
  spec {
    replicas = 2
    
    selector {
      match_labels = {
        app = "sample-nginx"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "sample-nginx"
        }
      }
      
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
          
          port {
            container_port = 80
          }
          
          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
  
  depends_on = [kubernetes_namespace.sample_app]
}

resource "kubernetes_service" "sample_nginx" {
  count = var.addons.aws_load_balancer_controller.enabled ? 1 : 0
  
  metadata {
    name      = "sample-nginx"
    namespace = "sample-app"
  }
  
  spec {
    selector = {
      app = "sample-nginx"
    }
    
    port {
      port        = 80
      target_port = 80
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [kubernetes_deployment.sample_nginx]
}

resource "kubernetes_ingress_v1" "sample_nginx" {
  count = var.addons.aws_load_balancer_controller.enabled ? 1 : 0
  
  metadata {
    name      = "sample-nginx"
    namespace = "sample-app"
    
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
    }
  }
  
  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = "sample-nginx"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  
  depends_on = [kubernetes_service.sample_nginx, helm_release.aws_load_balancer_controller]
}

# Data sources
data "aws_region" "current" {}
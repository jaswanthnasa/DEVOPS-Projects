# Quick Start Guide

Deploy your EKS cluster in under 10 minutes with this step-by-step guide.

## Prerequisites Checklist

- [ ] AWS CLI installed and configured
- [ ] Terraform >= 1.5 installed
- [ ] kubectl installed
- [ ] Appropriate AWS IAM permissions

### Required AWS Permissions

Your AWS user/role needs these permissions:
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`
- EC2, VPC, IAM, and CloudWatch permissions for infrastructure creation

## 5-Minute Development Deployment

### Step 1: Clone and Navigate
```bash
git clone <your-repo-url>
cd terraform-s3-project
```

### Step 2: Initialize Development Environment
```bash
make dev-init
```

### Step 3: Review and Customize (Optional)
```bash
# Copy example configuration
cp terraform.tfvars.example examples/dev/terraform.tfvars

# Edit if needed (optional for quick start)
# vim examples/dev/terraform.tfvars
```

### Step 4: Deploy
```bash
# Plan the deployment (review what will be created)
make dev-plan

# Apply the changes (this takes 10-15 minutes)
make dev-apply
```

### Step 5: Access Your Cluster
```bash
# Get kubeconfig
make get-kubeconfig ENV=dev

# Verify cluster is working
make verify-cluster ENV=dev
```

## What Gets Created

### Infrastructure
- **VPC**: 10.0.0.0/16 with public/private subnets across 3 AZs
- **EKS Cluster**: Kubernetes 1.28 with managed control plane
- **Node Groups**: 
  - System nodes: 2x t3.medium (ON_DEMAND)
  - Workload nodes: 1x t3.large (SPOT)
- **Security**: KMS encryption, security groups, IAM roles

### Add-ons Installed
- **AWS Managed**: VPC CNI, kube-proxy, CoreDNS, EBS CSI driver
- **Operational**: AWS Load Balancer Controller, Cluster Autoscaler, Metrics Server, Fluent Bit
- **Sample App**: Nginx with ALB ingress for testing

## Verification Checklist

After deployment, verify everything is working:

```bash
# ✅ Check cluster status
kubectl cluster-info

# ✅ Check nodes are ready
kubectl get nodes

# ✅ Check system pods are running
kubectl get pods -n kube-system

# ✅ Check addons are installed
helm list -A

# ✅ Check sample application
kubectl get ingress -n sample-app

# ✅ Test autoscaling (optional)
kubectl scale deployment sample-nginx --replicas=10 -n sample-app
```

## Expected Output

### Successful Node Check
```
NAME                                       STATUS   ROLES    AGE   VERSION
ip-10-0-100-123.us-east-1.compute.internal   Ready    <none>   5m    v1.28.3-eks-4f4795d
ip-10-0-101-456.us-east-1.compute.internal   Ready    <none>   5m    v1.28.3-eks-4f4795d
ip-10-0-102-789.us-east-1.compute.internal   Ready    <none>   5m    v1.28.3-eks-4f4795d
```

### Successful System Pods
```
NAMESPACE     NAME                                            READY   STATUS    RESTARTS   AGE
kube-system   aws-load-balancer-controller-xxx                2/2     Running   0          3m
kube-system   cluster-autoscaler-xxx                          1/1     Running   0          3m
kube-system   coredns-xxx                                     1/1     Running   0          8m
kube-system   ebs-csi-controller-xxx                          6/6     Running   0          3m
kube-system   kube-proxy-xxx                                  1/1     Running   0          8m
kube-system   metrics-server-xxx                              1/1     Running   0          3m
```

## Common Issues and Solutions

### Issue: Terraform init fails
**Solution**: Check AWS credentials and permissions
```bash
aws sts get-caller-identity
```

### Issue: Cluster creation times out
**Solution**: Check VPC and subnet configuration, ensure proper CIDR blocks

### Issue: Nodes not joining cluster
**Solution**: Check security groups and IAM roles
```bash
# Check node group status
aws eks describe-nodegroup --cluster-name eks-cluster-dev --nodegroup-name system
```

### Issue: Addons failing to install
**Solution**: Check IRSA configuration and addon compatibility
```bash
# Check addon status
aws eks describe-addon --cluster-name eks-cluster-dev --addon-name vpc-cni
```

### Issue: ALB not creating for sample app
**Solution**: Verify AWS Load Balancer Controller is running
```bash
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

## Next Steps

### Access Sample Application
```bash
# Get ALB hostname
kubectl get ingress sample-nginx -n sample-app

# Test the application
curl http://<alb-hostname>
```

### Deploy Your Applications
```bash
# Create your namespace
kubectl create namespace my-app

# Deploy your workloads
kubectl apply -f your-app.yaml -n my-app
```

### Monitor and Scale
```bash
# Watch cluster autoscaler logs
kubectl logs -f deployment/cluster-autoscaler -n kube-system

# Monitor resource usage
kubectl top nodes
kubectl top pods -A
```

## Production Deployment

For production deployment:

1. **Configure Backend**: Set up S3 and DynamoDB for state management
2. **Update Security**: Set `cluster_endpoint_public_access = false`
3. **Scale Resources**: Use larger instance types and higher capacity
4. **Enable Monitoring**: Set `enable_vpc_flow_logs = true`

```bash
# Deploy production environment
make prod-init
make prod-plan
make prod-apply
```

## Cleanup

To destroy the development environment:

```bash
make dev-destroy
```

**Warning**: This will delete all resources and cannot be undone!

## Cost Estimation

### Development Environment (Monthly)
- **EKS Control Plane**: ~$73
- **EC2 Instances**: ~$45 (2x t3.medium + 1x t3.large SPOT)
- **NAT Gateway**: ~$45 (single NAT)
- **EBS Storage**: ~$10
- **Total**: ~$173/month

### Cost Optimization Tips
- Use SPOT instances for non-critical workloads
- Enable Cluster Autoscaler to scale down during off-hours
- Use single NAT gateway for development
- Monitor and right-size your instances

## Support

- 📖 **Full Documentation**: See [README.md](README.md)
- 🔧 **Variables Reference**: See [VARIABLES.md](VARIABLES.md)
- 🐛 **Troubleshooting**: Check the troubleshooting section in README.md
- 💬 **Issues**: Open an issue in the repository

---

**🎉 Congratulations!** You now have a production-ready EKS cluster with all essential add-ons configured and ready for your applications.
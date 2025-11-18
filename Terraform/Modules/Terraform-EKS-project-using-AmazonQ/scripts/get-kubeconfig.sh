#!/bin/bash

# Script to update kubeconfig for EKS cluster
# Usage: ./get-kubeconfig.sh [environment] [region]

set -e

ENVIRONMENT=${1:-dev}
REGION=${2:-us-east-1}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Getting kubeconfig for EKS cluster...${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl is not installed. Please install it first.${NC}"
    exit 1
fi

# Get cluster name from Terraform output
CLUSTER_NAME=$(cd examples/${ENVIRONMENT} && terraform output -raw cluster_name 2>/dev/null || echo "")

if [ -z "$CLUSTER_NAME" ]; then
    echo -e "${RED}Could not get cluster name from Terraform output.${NC}"
    echo -e "${YELLOW}Make sure you have run 'terraform apply' in the examples/${ENVIRONMENT} directory.${NC}"
    exit 1
fi

echo -e "${GREEN}Found cluster: ${CLUSTER_NAME}${NC}"

# Update kubeconfig
echo -e "${YELLOW}Updating kubeconfig...${NC}"
aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}

# Verify connection
echo -e "${YELLOW}Verifying cluster connection...${NC}"
if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}Successfully connected to cluster!${NC}"
    echo -e "${GREEN}Cluster info:${NC}"
    kubectl cluster-info
    echo ""
    echo -e "${GREEN}Nodes:${NC}"
    kubectl get nodes
else
    echo -e "${RED}Failed to connect to cluster. Please check your AWS credentials and cluster status.${NC}"
    exit 1
fi
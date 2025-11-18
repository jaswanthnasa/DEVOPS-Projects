# Makefile for EKS Terraform project

.PHONY: help init plan apply destroy fmt validate clean get-kubeconfig verify-cluster

# Default environment
ENV ?= dev
REGION ?= us-east-1

# Colors
YELLOW := \033[1;33m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m

help: ## Show this help message
	@echo "$(YELLOW)EKS Terraform Project$(NC)"
	@echo "$(YELLOW)Usage: make [target] ENV=[dev|prod] REGION=[aws-region]$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

init: ## Initialize Terraform
	@echo "$(YELLOW)Initializing Terraform for $(ENV) environment...$(NC)"
	cd examples/$(ENV) && terraform init

plan: ## Plan Terraform changes
	@echo "$(YELLOW)Planning Terraform changes for $(ENV) environment...$(NC)"
	cd examples/$(ENV) && terraform plan -var-file=terraform.tfvars

apply: ## Apply Terraform changes
	@echo "$(YELLOW)Applying Terraform changes for $(ENV) environment...$(NC)"
	cd examples/$(ENV) && terraform apply -var-file=terraform.tfvars

destroy: ## Destroy Terraform resources
	@echo "$(RED)Destroying Terraform resources for $(ENV) environment...$(NC)"
	@echo "$(RED)This will delete all resources! Are you sure? [y/N]$(NC)" && read ans && [ $${ans:-N} = y ]
	cd examples/$(ENV) && terraform destroy -var-file=terraform.tfvars

fmt: ## Format Terraform files
	@echo "$(YELLOW)Formatting Terraform files...$(NC)"
	terraform fmt -recursive .

validate: ## Validate Terraform configuration
	@echo "$(YELLOW)Validating Terraform configuration...$(NC)"
	cd examples/$(ENV) && terraform validate

clean: ## Clean Terraform files
	@echo "$(YELLOW)Cleaning Terraform files...$(NC)"
	find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "terraform.tfstate*" -type f -delete 2>/dev/null || true
	find . -name ".terraform.lock.hcl" -type f -delete 2>/dev/null || true

get-kubeconfig: ## Get kubeconfig for the cluster
	@echo "$(YELLOW)Getting kubeconfig for $(ENV) environment...$(NC)"
	./scripts/get-kubeconfig.sh $(ENV) $(REGION)

verify-cluster: get-kubeconfig ## Verify cluster is working
	@echo "$(YELLOW)Verifying cluster functionality...$(NC)"
	@echo "$(GREEN)Checking nodes:$(NC)"
	kubectl get nodes
	@echo ""
	@echo "$(GREEN)Checking system pods:$(NC)"
	kubectl get pods -A
	@echo ""
	@echo "$(GREEN)Checking addons:$(NC)"
	kubectl get pods -n kube-system
	@echo ""
	@echo "$(GREEN)Checking sample application (if deployed):$(NC)"
	kubectl get ingress -n sample-app 2>/dev/null || echo "No sample application found"

# Backend setup helpers
setup-backend: ## Setup S3 backend and DynamoDB table
	@echo "$(YELLOW)Setting up Terraform backend...$(NC)"
	@echo "$(RED)Please create S3 bucket and DynamoDB table manually, then update backend.tf$(NC)"
	@echo "$(YELLOW)Example commands:$(NC)"
	@echo "aws s3 mb s3://your-terraform-state-bucket-$(ENV)"
	@echo "aws dynamodb create-table --table-name terraform-state-lock-$(ENV) --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5"

# Development helpers
dev-init: ENV=dev
dev-init: init ## Initialize dev environment

dev-plan: ENV=dev
dev-plan: plan ## Plan dev environment

dev-apply: ENV=dev
dev-apply: apply ## Apply dev environment

dev-destroy: ENV=dev
dev-destroy: destroy ## Destroy dev environment

# Production helpers
prod-init: ENV=prod
prod-init: init ## Initialize prod environment

prod-plan: ENV=prod
prod-plan: plan ## Plan prod environment

prod-apply: ENV=prod
prod-apply: apply ## Apply prod environment

prod-destroy: ENV=prod
prod-destroy: destroy ## Destroy prod environment
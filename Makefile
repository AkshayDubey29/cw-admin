# CreatWorx Admin Service Makefile
.PHONY: help install build test lint format clean dev start docker-build docker-push deploy-gcp deploy-k8s logs status

# Configuration
SERVICE_NAME := cw-admin
PROJECT_ID := createworx
REGISTRY := gcr.io
IMAGE_NAME := $(REGISTRY)/$(PROJECT_ID)/$(SERVICE_NAME)
VERSION := $(shell git describe --tags --always --dirty)
NAMESPACE := creatworx

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)CreatWorx Admin Service Commands:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

install: ## Install dependencies
	@echo "$(BLUE)Installing dependencies...$(NC)"
	npm ci

install-dev: ## Install development dependencies
	@echo "$(BLUE)Installing development dependencies...$(NC)"
	npm ci --include=dev

build: ## Build the application for production
	@echo "$(BLUE)Building application...$(NC)"
	npm run build

test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	npm test

test-watch: ## Run tests in watch mode
	@echo "$(BLUE)Running tests in watch mode...$(NC)"
	npm run test:watch

test-coverage: ## Run tests with coverage
	@echo "$(BLUE)Running tests with coverage...$(NC)"
	npm run test:coverage

lint: ## Run linting
	@echo "$(BLUE)Running linting...$(NC)"
	npm run lint

lint-fix: ## Fix linting issues
	@echo "$(BLUE)Fixing linting issues...$(NC)"
	npm run lint:fix

format: ## Format code
	@echo "$(BLUE)Formatting code...$(NC)"
	npm run format

format-check: ## Check code formatting
	@echo "$(BLUE)Checking code formatting...$(NC)"
	npm run format:check

type-check: ## Run TypeScript type checking
	@echo "$(BLUE)Running TypeScript type checking...$(NC)"
	npm run type-check

dev: ## Start development server
	@echo "$(BLUE)Starting development server...$(NC)"
	npm run dev

start: ## Start production server
	@echo "$(BLUE)Starting production server...$(NC)"
	npm start

clean: ## Clean build artifacts
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	rm -rf .next
	rm -rf out
	rm -rf dist
	rm -rf build
	rm -rf coverage
	rm -rf node_modules

docker-build: ## Build Docker image
	@echo "$(BLUE)Building Docker image...$(NC)"
	docker build -t $(IMAGE_NAME):$(VERSION) .
	docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest

docker-push: ## Push Docker image to registry
	@echo "$(BLUE)Pushing Docker image to registry...$(NC)"
	docker push $(IMAGE_NAME):$(VERSION)
	docker push $(IMAGE_NAME):latest

docker-run: ## Run Docker container locally
	@echo "$(BLUE)Running Docker container locally...$(NC)"
	docker run -p 3000:3000 --env-file .env.local $(IMAGE_NAME):latest

deploy-gcp: ## Deploy to Google Cloud Platform
	@echo "$(BLUE)Deploying to GCP...$(NC)"
	@echo "$(YELLOW)Building Docker image...$(NC)"
	$(MAKE) docker-build
	@echo "$(YELLOW)Pushing to GCR...$(NC)"
	$(MAKE) docker-push
	@echo "$(YELLOW)Deploying to GKE...$(NC)"
	$(MAKE) deploy-k8s

deploy-k8s: ## Deploy to Kubernetes
	@echo "$(BLUE)Deploying to Kubernetes...$(NC)"
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/secret.yaml
	sed 's|IMAGE_TAG|$(VERSION)|g' k8s/deployment.yaml | kubectl apply -f -
	kubectl apply -f k8s/service.yaml
	kubectl apply -f k8s/ingress.yaml
	kubectl apply -f k8s/hpa.yaml
	@echo "$(GREEN)Deployment completed!$(NC)"

logs: ## Show application logs
	@echo "$(BLUE)Showing application logs...$(NC)"
	kubectl logs -f deployment/$(SERVICE_NAME) -n $(NAMESPACE)

status: ## Show deployment status
	@echo "$(BLUE)Deployment status:$(NC)"
	kubectl get pods -n $(NAMESPACE) -l app=$(SERVICE_NAME)
	kubectl get svc -n $(NAMESPACE) -l app=$(SERVICE_NAME)
	kubectl get ingress -n $(NAMESPACE) -l app=$(SERVICE_NAME)
	kubectl get hpa -n $(NAMESPACE) -l app=$(SERVICE_NAME)

restart: ## Restart deployment
	@echo "$(BLUE)Restarting deployment...$(NC)"
	kubectl rollout restart deployment/$(SERVICE_NAME) -n $(NAMESPACE)

rollback: ## Rollback to previous deployment
	@echo "$(BLUE)Rolling back deployment...$(NC)"
	kubectl rollout undo deployment/$(SERVICE_NAME) -n $(NAMESPACE)

scale: ## Scale deployment (usage: make scale REPLICAS=5)
	@echo "$(BLUE)Scaling deployment to $(REPLICAS) replicas...$(NC)"
	kubectl scale deployment/$(SERVICE_NAME) --replicas=$(REPLICAS) -n $(NAMESPACE)

port-forward: ## Port forward to service
	@echo "$(BLUE)Port forwarding to service...$(NC)"
	kubectl port-forward svc/$(SERVICE_NAME)-service 3000:80 -n $(NAMESPACE)

health-check: ## Check application health
	@echo "$(BLUE)Checking application health...$(NC)"
	curl -f http://localhost:3000/api/health || echo "$(RED)Health check failed$(NC)"

security-scan: ## Run security scan
	@echo "$(BLUE)Running security scan...$(NC)"
	npm audit
	trivy image $(IMAGE_NAME):$(VERSION)

performance-test: ## Run performance tests
	@echo "$(BLUE)Running performance tests...$(NC)"
	npm install -g artillery
	artillery run tests/performance/load-test.yml

backup: ## Create backup
	@echo "$(BLUE)Creating backup...$(NC)"
	kubectl get all -n $(NAMESPACE) -l app=$(SERVICE_NAME) -o yaml > backup/$(SERVICE_NAME)-$(shell date +%Y%m%d-%H%M%S).yaml

restore: ## Restore from backup
	@echo "$(BLUE)Restoring from backup...$(NC)"
	kubectl apply -f backup/$(BACKUP_FILE)

# Development helpers
setup-dev: install-dev ## Setup development environment
	@echo "$(GREEN)Development environment setup complete!$(NC)"

ci: install lint type-check test build ## Run CI pipeline
	@echo "$(GREEN)CI pipeline completed successfully!$(NC)"

# Utility targets
version: ## Show version information
	@echo "$(BLUE)Version Information:$(NC)"
	@echo "Service: $(SERVICE_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Image: $(IMAGE_NAME):$(VERSION)"
	@echo "Project: $(PROJECT_ID)"
	@echo "Namespace: $(NAMESPACE)"

check-prerequisites: ## Check if all prerequisites are installed
	@echo "$(BLUE)Checking prerequisites...$(NC)"
	@command -v node >/dev/null 2>&1 || { echo "$(RED)Node.js is required but not installed$(NC)"; exit 1; }
	@command -v npm >/dev/null 2>&1 || { echo "$(RED)npm is required but not installed$(NC)"; exit 1; }
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)Docker is required but not installed$(NC)"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "$(RED)kubectl is required but not installed$(NC)"; exit 1; }
	@command -v gcloud >/dev/null 2>&1 || { echo "$(RED)gcloud is required but not installed$(NC)"; exit 1; }
	@echo "$(GREEN)All prerequisites are installed$(NC)"

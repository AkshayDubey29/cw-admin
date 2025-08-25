#!/bin/bash

# CreatWorx Admin - GCP Deployment Script
# This script deploys cw-admin to GCP using pre-built Docker images from CI/CD

set -e

# Configuration
PROJECT_ID="createworx"
CLUSTER_NAME="creatworx-cluster"
CLUSTER_REGION="us-central1"
NAMESPACE="creatworx"
IMAGE_NAME="gcr.io/createworx/cw-admin"
IMAGE_TAG=${1:-"latest"}  # Use provided tag or default to latest

# Check if we're doing initial deployment with nginx
INITIAL_DEPLOYMENT=false
if [[ "$1" == "deploy" || "$1" == "" ]]; then
    INITIAL_DEPLOYMENT=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if gcloud is installed
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install it first."
        exit 1
    fi
    
    # Check if user is authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "Not authenticated with gcloud. Please run 'gcloud auth login' first."
        exit 1
    fi
    
    print_success "All prerequisites are satisfied"
}

# Function to configure GCP
configure_gcp() {
    print_status "Configuring GCP..."
    
    # Set the project
    gcloud config set project $PROJECT_ID
    
    # Configure Docker for GCR
    gcloud auth configure-docker --quiet
    
    print_success "GCP configured successfully"
}

# Function to get cluster credentials
get_cluster_credentials() {
    print_status "Getting cluster credentials..."
    
    gcloud container clusters get-credentials $CLUSTER_NAME \
        --region $CLUSTER_REGION \
        --project $PROJECT_ID
    
    print_success "Cluster credentials obtained"
}

# Function to check if image exists
check_image_exists() {
    print_status "Checking if Docker image exists..."
    
    # Skip image check for initial deployment since we're using nginx:alpine
    if [[ "$INITIAL_DEPLOYMENT" == "true" ]]; then
        print_warning "Using nginx:alpine for initial deployment"
        print_status "CI/CD pipeline will build and push the actual cw-admin image"
        return 0
    fi
    
    if ! gcloud container images describe $IMAGE_NAME:$IMAGE_TAG &> /dev/null; then
        print_warning "Image $IMAGE_NAME:$IMAGE_TAG not found in GCR"
        print_status "Available tags:"
        gcloud container images list-tags $IMAGE_NAME --limit=10 --format="table(tags,timestamp.datetime)" 2>/dev/null || echo "No tags found"
        print_error "Please ensure the image is built and pushed via CI/CD pipeline first"
        exit 1
    fi
    
    print_success "Image $IMAGE_NAME:$IMAGE_TAG found in GCR"
}

# Function to deploy to Kubernetes
deploy_to_kubernetes() {
    print_status "Deploying to Kubernetes..."
    
    # Create namespace if it doesn't exist
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Update image tag in deployment (only for non-initial deployments)
    if [[ "$INITIAL_DEPLOYMENT" == "true" ]]; then
        cp k8s/deployment.yaml k8s/deployment-temp.yaml
    else
        sed "s|IMAGE_TAG|$IMAGE_TAG|g" k8s/deployment.yaml > k8s/deployment-temp.yaml
    fi
    
    # Apply Kubernetes manifests
    print_status "Applying Kubernetes manifests..."
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/configmap.yaml
    kubectl apply -f k8s/secret.yaml
    kubectl apply -f k8s/deployment-temp.yaml
    kubectl apply -f k8s/service.yaml
    kubectl apply -f k8s/ingress.yaml
    kubectl apply -f k8s/hpa.yaml
    
    # Clean up temporary file
    rm -f k8s/deployment-temp.yaml
    
    print_success "Kubernetes manifests applied successfully"
}

# Function to wait for deployment
wait_for_deployment() {
    print_status "Waiting for deployment to be ready..."
    
    kubectl rollout status deployment/cw-admin -n $NAMESPACE --timeout=300s
    
    print_success "Deployment is ready"
}

# Function to verify deployment
verify_deployment() {
    print_status "Verifying deployment..."
    
    echo ""
    echo "=== Pods ==="
    kubectl get pods -n $NAMESPACE -l app=cw-admin
    
    echo ""
    echo "=== Services ==="
    kubectl get svc -n $NAMESPACE -l app=cw-admin
    
    echo ""
    echo "=== Ingress ==="
    kubectl get ingress -n $NAMESPACE -l app=cw-admin
    
    echo ""
    echo "=== HPA ==="
    kubectl get hpa -n $NAMESPACE -l app=cw-admin
    
    print_success "Deployment verification completed"
}

# Function to show access information
show_access_info() {
    print_status "Getting access information..."
    
    echo ""
    echo "=== Access Information ==="
    echo "Service URL: https://admin.creatworx.com"
    echo "GCP Console: https://console.cloud.google.com/kubernetes/clusters/details/$CLUSTER_REGION/$CLUSTER_NAME"
    echo "Image: $IMAGE_NAME:$IMAGE_TAG"
    
    # Get external IP if available
    EXTERNAL_IP=$(kubectl get ingress cw-admin-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "Pending")
    echo "External IP: $EXTERNAL_IP"
    
    print_success "Deployment completed successfully!"
}

# Function to show logs
show_logs() {
    print_status "Showing recent logs..."
    
    kubectl logs -n $NAMESPACE -l app=cw-admin --tail=50
}

# Main deployment function
main() {
    echo "🚀 CreatWorx Admin - GCP Deployment"
    echo "=================================="
    echo "Project: $PROJECT_ID"
    echo "Cluster: $CLUSTER_NAME"
    echo "Region: $CLUSTER_REGION"
    echo "Namespace: $NAMESPACE"
    echo "Image: $IMAGE_NAME:$IMAGE_TAG"
    echo ""
    
    check_prerequisites
    configure_gcp
    get_cluster_credentials
    check_image_exists
    deploy_to_kubernetes
    wait_for_deployment
    verify_deployment
    show_access_info
    
    echo ""
    print_success "🎉 cw-admin has been successfully deployed to GCP!"
    echo ""
    echo "To view logs: ./scripts/deploy-to-gcp.sh logs"
    echo "To check status: kubectl get pods -n $NAMESPACE -l app=cw-admin"
}

# Handle different commands
case "${1:-deploy}" in
    "deploy")
        main
        ;;
    "logs")
        get_cluster_credentials
        show_logs
        ;;
    "status")
        get_cluster_credentials
        verify_deployment
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [COMMAND] [IMAGE_TAG]"
        echo ""
        echo "Commands:"
        echo "  deploy    Deploy cw-admin to GCP (default)"
        echo "  logs      Show recent logs"
        echo "  status    Show deployment status"
        echo "  help      Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0                    # Deploy with latest tag"
        echo "  $0 deploy main-abc123 # Deploy with specific tag"
        echo "  $0 logs               # Show logs"
        echo "  $0 status             # Show status"
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

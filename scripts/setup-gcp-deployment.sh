#!/bin/bash

# CreatWorx Admin - GCP Deployment Setup Script
# This script helps set up the necessary GCP resources for deployment

set -e

# Configuration
PROJECT_ID="createworx"
SERVICE_ACCOUNT_NAME="github-actions"
SERVICE_ACCOUNT_DISPLAY_NAME="GitHub Actions"
SERVICE_ACCOUNT_DESCRIPTION="Service account for GitHub Actions CI/CD"

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
    
    # Check if user is authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "Not authenticated with gcloud. Please run 'gcloud auth login' first."
        exit 1
    fi
    
    print_success "All prerequisites are satisfied"
}

# Function to set up GCP project
setup_project() {
    print_status "Setting up GCP project..."
    
    # Set the project
    gcloud config set project $PROJECT_ID
    
    # Enable required APIs
    print_status "Enabling required APIs..."
    gcloud services enable container.googleapis.com
    gcloud services enable containerregistry.googleapis.com
    gcloud services enable compute.googleapis.com
    
    print_success "GCP project configured successfully"
}

# Function to create service account
create_service_account() {
    print_status "Creating service account for GitHub Actions..."
    
    # Check if service account already exists
    if gcloud iam service-accounts describe $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com &> /dev/null; then
        print_warning "Service account already exists"
        return 0
    fi
    
    # Create service account
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
        --display-name="$SERVICE_ACCOUNT_DISPLAY_NAME" \
        --description="$SERVICE_ACCOUNT_DESCRIPTION"
    
    print_success "Service account created successfully"
}

# Function to grant permissions
grant_permissions() {
    print_status "Granting necessary permissions..."
    
    # Grant Container Developer role
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/container.developer"
    
    # Grant Storage Admin role
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/storage.admin"
    
    # Grant Service Account User role
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/iam.serviceAccountUser"
    
    print_success "Permissions granted successfully"
}

# Function to create and download key
create_service_account_key() {
    print_status "Creating service account key..."
    
    # Create key file
    KEY_FILE="github-actions-key.json"
    gcloud iam service-accounts keys create $KEY_FILE \
        --iam-account=$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com
    
    # Base64 encode the key
    BASE64_KEY=$(base64 -i $KEY_FILE)
    
    print_success "Service account key created successfully"
    echo ""
    echo "=== GITHUB SECRET SETUP ==="
    echo "1. Go to your GitHub repository: https://github.com/AkshayDubey29/cw-admin"
    echo "2. Navigate to Settings > Secrets and variables > Actions"
    echo "3. Click 'New repository secret'"
    echo "4. Name: GCP_SA_KEY"
    echo "5. Value: (copy the base64 encoded key below)"
    echo ""
    echo "Base64 encoded key:"
    echo "$BASE64_KEY"
    echo ""
    echo "=== NEXT STEPS ==="
    echo "1. Add the secret to GitHub as shown above"
    echo "2. Push your code to trigger CI/CD: git push origin main"
    echo "3. Monitor the deployment in GitHub Actions"
    echo ""
    
    # Clean up key file
    rm -f $KEY_FILE
    print_warning "Key file removed for security"
}

# Function to verify cluster
verify_cluster() {
    print_status "Verifying GKE cluster..."
    
    # Check if cluster exists
    if ! gcloud container clusters describe creatworx-cluster --region us-central1 &> /dev/null; then
        print_error "Cluster 'creatworx-cluster' not found in us-central1"
        print_status "Please ensure the cluster is created via cw-infra module"
        return 1
    fi
    
    print_success "GKE cluster verified successfully"
}

# Function to show deployment status
show_deployment_status() {
    print_status "Checking deployment status..."
    
    # Get cluster credentials
    gcloud container clusters get-credentials creatworx-cluster \
        --region us-central1 \
        --project $PROJECT_ID
    
    # Check if namespace exists
    if kubectl get namespace creatworx &> /dev/null; then
        print_success "Namespace 'creatworx' exists"
        
        # Check if deployment exists
        if kubectl get deployment cw-admin -n creatworx &> /dev/null; then
            print_success "Deployment 'cw-admin' exists"
            
            # Show pod status
            echo ""
            echo "=== POD STATUS ==="
            kubectl get pods -n creatworx -l app=cw-admin
            
            # Show service status
            echo ""
            echo "=== SERVICE STATUS ==="
            kubectl get svc -n creatworx -l app=cw-admin
            
            # Show ingress status
            echo ""
            echo "=== INGRESS STATUS ==="
            kubectl get ingress -n creatworx -l app=cw-admin
        else
            print_warning "Deployment 'cw-admin' not found"
        fi
    else
        print_warning "Namespace 'creatworx' not found"
    fi
}

# Main function
main() {
    echo "🔧 CreatWorx Admin - GCP Deployment Setup"
    echo "========================================="
    echo "Project: $PROJECT_ID"
    echo "Service Account: $SERVICE_ACCOUNT_NAME"
    echo ""
    
    check_prerequisites
    setup_project
    create_service_account
    grant_permissions
    create_service_account_key
    verify_cluster
    
    echo ""
    print_success "🎉 GCP deployment setup completed!"
    echo ""
    echo "To deploy the application:"
    echo "1. Add the GCP_SA_KEY secret to GitHub"
    echo "2. Push code to trigger CI/CD: git push origin main"
    echo "3. Monitor deployment in GitHub Actions"
    echo ""
    echo "For manual deployment, use: ./scripts/deploy-to-gcp.sh"
}

# Handle different commands
case "${1:-setup}" in
    "setup")
        main
        ;;
    "status")
        verify_cluster
        show_deployment_status
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  setup    Set up GCP resources for deployment (default)"
        echo "  status   Check deployment status"
        echo "  help     Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0        # Set up GCP resources"
        echo "  $0 status # Check deployment status"
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

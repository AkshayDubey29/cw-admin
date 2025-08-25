# CreatWorx Admin - Deployment Guide

This guide explains how to deploy the cw-admin service to Google Cloud Platform using the CI/CD pipeline.

## 🚀 Deployment Options

### Option 1: Automated CI/CD Pipeline (Recommended)

The service includes a comprehensive GitHub Actions CI/CD pipeline that automatically:
1. Builds and tests the application
2. Builds Docker image and pushes to GCR
3. Deploys to GKE cluster
4. Runs security scans and performance tests

#### Prerequisites for CI/CD:

1. **GitHub Repository**: Ensure the code is pushed to GitHub
2. **GCP Service Account**: Create a service account with necessary permissions
3. **GitHub Secrets**: Configure the following secrets in your GitHub repository

#### Required GitHub Secrets:

```bash
GCP_SA_KEY: <base64-encoded-service-account-key>
```

#### Steps to Enable CI/CD:

1. **Create GCP Service Account**:
   ```bash
   # Create service account
   gcloud iam service-accounts create github-actions \
     --display-name="GitHub Actions" \
     --description="Service account for GitHub Actions CI/CD"
   
   # Grant necessary roles
   gcloud projects add-iam-policy-binding createworx \
     --member="serviceAccount:github-actions@createworx.iam.gserviceaccount.com" \
     --role="roles/container.developer"
   
   gcloud projects add-iam-policy-binding createworx \
     --member="serviceAccount:github-actions@createworx.iam.gserviceaccount.com" \
     --role="roles/storage.admin"
   
   gcloud projects add-iam-policy-binding createworx \
     --member="serviceAccount:github-actions@createworx.iam.gserviceaccount.com" \
     --role="roles/iam.serviceAccountUser"
   
   # Create and download key
   gcloud iam service-accounts keys create ~/github-actions-key.json \
     --iam-account=github-actions@createworx.iam.gserviceaccount.com
   
   # Base64 encode the key
   base64 -i ~/github-actions-key.json
   ```

2. **Add Secret to GitHub**:
   - Go to your GitHub repository
   - Navigate to Settings > Secrets and variables > Actions
   - Add new repository secret: `GCP_SA_KEY`
   - Paste the base64-encoded service account key

3. **Trigger Deployment**:
   ```bash
   # Push to main branch to trigger CI/CD
   git push origin main
   ```

### Option 2: Manual Deployment via Cloud Shell

If you prefer to deploy manually or need to troubleshoot:

#### Prerequisites:
- Access to Google Cloud Console
- GKE cluster running (creatworx-cluster)

#### Steps:

1. **Open Google Cloud Shell**:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Click the Cloud Shell icon (terminal icon)

2. **Clone and Setup**:
   ```bash
   # Clone the repository
   git clone https://github.com/AkshayDubey29/cw-admin.git
   cd cw-admin
   
   # Set project
   gcloud config set project createworx
   
   # Get cluster credentials
   gcloud container clusters get-credentials creatworx-cluster \
     --region us-central1 \
     --project createworx
   ```

3. **Build and Push Docker Image**:
   ```bash
   # Configure Docker for GCR
   gcloud auth configure-docker
   
   # Build and push image
   docker build -t gcr.io/createworx/cw-admin:latest .
   docker push gcr.io/createworx/cw-admin:latest
   ```

4. **Deploy to Kubernetes**:
   ```bash
   # Update deployment with correct image tag
   sed -i "s|IMAGE_TAG|latest|g" k8s/deployment.yaml
   
   # Apply manifests
   kubectl apply -f k8s/namespace.yaml
   kubectl apply -f k8s/configmap.yaml
   kubectl apply -f k8s/secret.yaml
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/ingress.yaml
   kubectl apply -f k8s/hpa.yaml
   ```

5. **Verify Deployment**:
   ```bash
   # Check deployment status
   kubectl get pods -n creatworx -l app=cw-admin
   kubectl get svc -n creatworx -l app=cw-admin
   kubectl get ingress -n creatworx -l app=cw-admin
   ```

### Option 3: Local Development Deployment

For development and testing:

1. **Build Locally**:
   ```bash
   npm run build
   ```

2. **Run with Docker**:
   ```bash
   docker build -t cw-admin:local .
   docker run -p 3000:3000 cw-admin:local
   ```

3. **Access Application**:
   - Open browser to `http://localhost:3000`

## 🔧 Configuration

### Environment Variables

The application uses the following environment variables:

```bash
# API Configuration
NEXT_PUBLIC_API_URL=https://api.creatworx.com

# Authentication
JWT_SECRET=your-jwt-secret

# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Redis
REDIS_URL=redis://host:port/0

# Application
NODE_ENV=production
NEXT_PUBLIC_APP_NAME=CreatWorx Admin
NEXT_PUBLIC_APP_VERSION=1.0.0
```

### Kubernetes Configuration

The deployment uses:
- **Namespace**: `creatworx`
- **Replicas**: 2 (with HPA scaling 2-10)
- **Resources**: 128Mi-256Mi memory, 100m-200m CPU
- **Health Checks**: Liveness and readiness probes
- **Security**: Non-root user, read-only filesystem

## 📊 Monitoring

### Health Checks

The application provides health endpoints:
- **Health Check**: `GET /api/health`
- **Readiness Probe**: `GET /`
- **Liveness Probe**: `GET /`

### Logs

View application logs:
```bash
# View logs
kubectl logs -n creatworx -l app=cw-admin

# Follow logs
kubectl logs -n creatworx -l app=cw-admin -f

# View logs for specific pod
kubectl logs -n creatworx <pod-name>
```

### Metrics

Monitor the deployment:
```bash
# Check pod status
kubectl get pods -n creatworx -l app=cw-admin

# Check service status
kubectl get svc -n creatworx -l app=cw-admin

# Check ingress status
kubectl get ingress -n creatworx -l app=cw-admin

# Check HPA status
kubectl get hpa -n creatworx -l app=cw-admin
```

## 🔒 Security

### Security Features

- **HTTPS**: Enforced via ingress
- **Non-root User**: Container runs as non-root
- **Read-only Filesystem**: Container filesystem is read-only
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, etc.
- **Input Validation**: Zod schema validation
- **CORS**: Configured for specific domains

### Secrets Management

Sensitive data is stored in Kubernetes secrets:
```bash
# Update secrets
kubectl create secret generic cw-admin-secret \
  --from-literal=JWT_SECRET=your-jwt-secret \
  --from-literal=DATABASE_URL=your-database-url \
  --from-literal=REDIS_URL=your-redis-url \
  -n creatworx
```

## 🚨 Troubleshooting

### Common Issues

1. **Cluster Connectivity**:
   ```bash
   # Check cluster status
   gcloud container clusters describe creatworx-cluster --region us-central1
   
   # Get credentials
   gcloud container clusters get-credentials creatworx-cluster --region us-central1
   ```

2. **Image Pull Issues**:
   ```bash
   # Check if image exists
   gcloud container images list-tags gcr.io/createworx/cw-admin
   
   # Pull image manually
   docker pull gcr.io/createworx/cw-admin:latest
   ```

3. **Pod Issues**:
   ```bash
   # Describe pod for details
   kubectl describe pod <pod-name> -n creatworx
   
   # Check events
   kubectl get events -n creatworx --sort-by='.lastTimestamp'
   ```

4. **Ingress Issues**:
   ```bash
   # Check ingress status
   kubectl describe ingress cw-admin-ingress -n creatworx
   
   # Check if external IP is assigned
   kubectl get ingress -n creatworx
   ```

### Debug Commands

```bash
# Port forward for local access
kubectl port-forward svc/cw-admin-service 3000:80 -n creatworx

# Execute commands in pod
kubectl exec -it <pod-name> -n creatworx -- /bin/sh

# View pod logs
kubectl logs <pod-name> -n creatworx

# Check resource usage
kubectl top pods -n creatworx
```

## 📈 Scaling

### Horizontal Pod Autoscaler

The deployment includes an HPA that scales based on:
- **CPU**: 70% utilization
- **Memory**: 80% utilization
- **Min Replicas**: 2
- **Max Replicas**: 10

### Manual Scaling

```bash
# Scale manually
kubectl scale deployment cw-admin --replicas=5 -n creatworx

# Check HPA status
kubectl get hpa cw-admin-hpa -n creatworx
```

## 🔄 Updates and Rollbacks

### Rolling Updates

```bash
# Update deployment
kubectl set image deployment/cw-admin cw-admin=gcr.io/createworx/cw-admin:new-tag -n creatworx

# Check rollout status
kubectl rollout status deployment/cw-admin -n creatworx
```

### Rollbacks

```bash
# Rollback to previous version
kubectl rollout undo deployment/cw-admin -n creatworx

# Rollback to specific revision
kubectl rollout undo deployment/cw-admin --to-revision=2 -n creatworx
```

## 📞 Support

For issues and support:
- **GitHub Issues**: Create an issue in the repository
- **Documentation**: Check the README.md file
- **Logs**: Use the monitoring commands above

---

**Note**: This deployment guide assumes you have the necessary GCP permissions and the cluster is properly configured. For cluster setup, refer to the cw-infra module documentation.

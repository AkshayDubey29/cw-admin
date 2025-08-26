# Namespace Strategy and Node Taint Handling

## Overview

This document outlines the namespace strategy and node taint handling for the CreatWorx platform services.

## Namespace Strategy

### Service-Specific Namespaces

Each service in the CreatWorx platform now has its own dedicated namespace for better isolation, security, and resource management:

- `cw-admin` - Admin dashboard and frontend
- `cw-auth` - Authentication service
- `cw-content` - Content management service
- `cw-api-gateway` - API Gateway service
- `cw-users` - User management service
- `cw-analytics` - Analytics service
- `cw-notifications` - Notification service
- `cw-billing` - Billing service
- `cw-search` - Search service
- `cw-recommendations` - Recommendation service
- `cw-moderation` - Content moderation service
- `cw-upload` - File upload service
- `cw-transcode-orch` - Transcoding orchestration service
- `cw-security` - Security service
- `cw-testing` - Testing service

### Benefits of Service-Specific Namespaces

1. **Security Isolation**: Services cannot access resources from other namespaces by default
2. **Resource Quotas**: Each namespace can have its own resource limits
3. **Network Policies**: Fine-grained network control between services
4. **RBAC**: Service-specific role-based access control
5. **Monitoring**: Better observability and metrics per service
6. **Backup/Restore**: Service-specific backup strategies
7. **Deployment**: Independent deployment and rollback per service

## Node Taint Handling

### Node Taints in Production

The GKE cluster uses node taints to ensure proper workload placement:

- **Production Nodes**: `dedicated=production:NoSchedule`
- **Foundation Nodes**: `dedicated=foundation:NoSchedule`

### Tolerations and Node Selectors

Each service deployment includes:

```yaml
spec:
  template:
    spec:
      # Tolerations for node taints
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "production"
        effect: "NoSchedule"
      
      # Node selector to prefer production nodes
      nodeSelector:
        dedicated: "production"
```

### Service Classification

- **Production Services**: Use production nodes with `dedicated=production` taint
- **Foundation Services**: Use foundation nodes with `dedicated=foundation` taint
- **Shared Services**: Can tolerate both taints

## Service Communication

### Inter-Service Communication

Services communicate through:

1. **Kubernetes Services**: Internal service discovery
2. **API Gateway**: Centralized API management
3. **Service Mesh**: Future implementation for advanced traffic management

### Example Service Communication

```yaml
# cw-admin calling cw-auth
apiVersion: v1
kind: Service
metadata:
  name: cw-auth-service
  namespace: cw-auth
spec:
  selector:
    app: cw-auth
  ports:
  - port: 80
    targetPort: 8080
```

## Templates

### Namespace Template

Use `k8s/namespace-template.yaml` as a base for new service namespaces.

### Deployment Template

Use `k8s/deployment-template.yaml` as a base for new service deployments.

## Best Practices

1. **Always use service-specific namespaces**
2. **Include proper tolerations and node selectors**
3. **Use resource limits and requests**
4. **Implement health checks and readiness probes**
5. **Use security contexts for containers**
6. **Apply network policies for service isolation**
7. **Monitor resource usage per namespace**

## Migration Guide

To migrate existing services to service-specific namespaces:

1. Create new namespace using the template
2. Update all K8s manifests to use new namespace
3. Add tolerations and node selectors to deployments
4. Update CI/CD pipelines to use new namespace
5. Test service communication
6. Remove old namespace after verification

## Monitoring and Observability

- **Namespace Metrics**: Monitor resource usage per namespace
- **Service Dependencies**: Track inter-service communication
- **Network Policies**: Monitor network policy effectiveness
- **Security Events**: Track security-related events per namespace

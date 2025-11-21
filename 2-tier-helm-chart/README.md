# 2-Tier Application Helm Chart

A Helm chart for deploying a 2-tier Flask web application with MySQL database on Kubernetes.

## 📋 Overview

This chart deploys:
- **MySQL Database** (1 replica by default)
  - Persistent storage
  - Secrets for credentials
  - ClusterIP service
- **Flask Web Application** (2 replicas by default)
  - ConfigMap for configuration
  - Health probes
  - NodePort service for external access

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (kind, minikube, or any K8s cluster)
- Helm 3.x installed
- kubectl configured
- webapp:latest Docker image built and loaded into cluster

### Install

```bash
# Install with default values
helm install my-2tier-app .

# Install with custom values
helm install my-2tier-app . -f my-values.yaml

# Install with specific values
helm install my-2tier-app . --set webapp.replicas=3
```

### Verify

```bash
# Check release status
helm status my-2tier-app

# Check pods
kubectl get pods

# Access application
curl http://localhost:30080
```

### Upgrade

```bash
helm upgrade my-2tier-app . --set webapp.replicas=4
```

### Uninstall

```bash
helm uninstall my-2tier-app
```

## ⚙️ Configuration

### Key Configuration Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mysql.replicas` | Number of MySQL replicas | `1` |
| `mysql.image.repository` | MySQL image repository | `mysql` |
| `mysql.image.tag` | MySQL image tag | `8.0` |
| `mysql.auth.rootPassword` | MySQL root password | `rootpassword` |
| `mysql.auth.database` | Database name | `keyvaluedb` |
| `mysql.auth.username` | MySQL user | `dbuser` |
| `mysql.auth.password` | MySQL password | `dbpassword` |
| `mysql.persistence.enabled` | Enable persistence | `true` |
| `mysql.persistence.size` | PVC size | `1Gi` |
| `webapp.replicas` | Number of webapp replicas | `2` |
| `webapp.image.repository` | Webapp image repository | `webapp` |
| `webapp.image.tag` | Webapp image tag | `latest` |
| `webapp.service.type` | Service type | `NodePort` |
| `webapp.service.nodePort` | NodePort value | `30080` |

### Example Custom Values

```yaml
# Production configuration
mysql:
  replicas: 1
  persistence:
    size: 10Gi
  resources:
    requests:
      memory: 512Mi
      cpu: 500m

webapp:
  replicas: 5
  service:
    nodePort: 30080
  resources:
    requests:
      memory: 256Mi
      cpu: 200m
```

## 📁 Chart Structure

```
2-tier-helm-chart/
├── Chart.yaml                      # Chart metadata
├── values.yaml                     # Default configuration values
├── .helmignore                    # Files to ignore
├── README.md                      # This file
└── templates/                     # Kubernetes manifests templates
    ├── _helpers.tpl               # Template helpers
    ├── mysql-secret.yaml          # MySQL credentials
    ├── mysql-pvc.yaml             # Persistent volume claim
    ├── mysql-deployment.yaml      # MySQL deployment
    ├── mysql-service.yaml         # MySQL service
    ├── webapp-configmap.yaml      # Webapp configuration
    ├── webapp-deployment.yaml     # Webapp deployment
    └── webapp-service.yaml        # Webapp service
```

## 🔍 Template Features

### Conditionals
- Components can be enabled/disabled via `enabled` flags
- Persistence can be toggled for MySQL

### Labels & Selectors
- Standard Kubernetes labels
- Helm-specific labels for tracking
- Custom labels for tiers (frontend/database)

### Resource Management
- Configurable resource requests and limits
- Default values suitable for development

### Health Checks
- Liveness and readiness probes for webapp
- Configurable probe settings

## 🛠️ Development

### Lint the Chart

```bash
helm lint .
```

### Test Template Rendering

```bash
# Render all templates
helm template my-2tier-app .

# Save rendered output
helm template my-2tier-app . > rendered.yaml

# Dry run installation
helm install my-2tier-app . --dry-run --debug
```

### Package the Chart

```bash
helm package .
# Creates: 2-tier-app-0.1.0.tgz
```

## 🌍 Different Environments

### Development

```yaml
# values-dev.yaml
mysql:
  persistence:
    size: 500Mi
webapp:
  replicas: 1
  service:
    nodePort: 30090
```

```bash
helm install dev-app . -f values-dev.yaml -n dev
```

### Staging

```yaml
# values-staging.yaml
mysql:
  persistence:
    size: 5Gi
webapp:
  replicas: 2
  service:
    nodePort: 30080
```

```bash
helm install staging-app . -f values-staging.yaml -n staging
```

### Production

```yaml
# values-prod.yaml
mysql:
  persistence:
    size: 10Gi
  resources:
    requests:
      memory: 512Mi
      cpu: 500m
webapp:
  replicas: 5
  resources:
    requests:
      memory: 256Mi
      cpu: 200m
```

```bash
helm install prod-app . -f values-prod.yaml -n production
```

## 🔐 Security Notes

⚠️ **Important**: The default credentials in `values.yaml` are for demonstration only!

For production:
1. Use Kubernetes Secrets or external secret management (e.g., HashiCorp Vault)
2. Enable RBAC
3. Use network policies
4. Regularly update images
5. Scan for vulnerabilities

## 📊 Monitoring

To monitor the application:

```bash
# Watch pods
kubectl get pods -w

# Check logs
kubectl logs -f deployment/my-2tier-app-webapp
kubectl logs -f deployment/my-2tier-app-mysql

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Port forward for direct access
kubectl port-forward svc/webapp-service 8080:80
```

## 🐛 Troubleshooting

### Pods not starting

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Image pull errors (kind cluster)

```bash
# Ensure image is loaded into kind
kind load docker-image webapp:latest --name demo-cluster
```

### Database connection issues

```bash
# Check if MySQL service is accessible
kubectl exec -it <webapp-pod> -- ping mysql-service

# Verify environment variables
kubectl exec -it <webapp-pod> -- env | grep DB_
```

### Helm release issues

```bash
# Check release status
helm status my-2tier-app

# Get all release information
helm get all my-2tier-app

# View generated manifests
helm get manifest my-2tier-app
```

## 📚 Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📄 License

This chart is provided as-is for educational purposes.

## 👥 Maintainers

- Anitha Priya (@anithapriyanatarajan)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

---

**Happy Helming! 🎉**

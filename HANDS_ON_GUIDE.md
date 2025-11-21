# 🚀 Hands-On Helm Guide: Deploy Your 2-Tier App

This is your **practical step-by-step guide** to deploy the 2-tier application using Helm!

---

## 📋 Prerequisites Checklist

Before we start, make sure you have:

- [ ] kind cluster running
- [ ] kubectl installed and configured
- [ ] Helm 3 installed
- [ ] Docker installed
- [ ] webapp:latest image built (from the app/ directory)

---

## 🎯 Part 1: Verify Your Setup

### Step 1: Check if kind cluster exists

```bash
kind get clusters
```

**If no cluster exists:**
```bash
kind create cluster --name demo-cluster
```

### Step 2: Verify Helm installation

```bash
helm version
```

**Expected output:**
```
version.BuildInfo{Version:"v3.x.x", ...}
```

**If Helm is not installed:**
```bash
# Install Helm (Linux)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Step 3: Build the webapp Docker image (if not already built)

```bash
cd /home/anataraj/Projects/cka/2-tier-app/app
docker build -t webapp:latest .

# Load image into kind cluster
kind load docker-image webapp:latest --name demo-cluster
```

---

## 🏗️ Part 2: Explore the Helm Chart

### Step 1: Navigate to the chart directory

```bash
cd /home/anataraj/Projects/cka/2-tier-app/2-tier-helm-chart
```

### Step 2: Examine the chart structure

```bash
tree .
# Or
ls -R
```

**You should see:**
```
.
├── Chart.yaml              # Chart metadata
├── values.yaml             # Configuration values
├── .helmignore            # Files to ignore
└── templates/             # Kubernetes templates
    ├── _helpers.tpl
    ├── mysql-deployment.yaml
    ├── mysql-pvc.yaml
    ├── mysql-secret.yaml
    ├── mysql-service.yaml
    ├── webapp-configmap.yaml
    ├── webapp-deployment.yaml
    └── webapp-service.yaml
```

### Step 3: View the Chart metadata

```bash
cat Chart.yaml
```

### Step 4: View default values

```bash
cat values.yaml
```

---

## 🔍 Part 3: Validate the Helm Chart

Before installing, let's make sure everything is correct!

### Step 1: Lint the chart (check for errors)

```bash
helm lint .
```

**✅ Expected output:**
```
==> Linting .
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

### Step 2: Dry run (preview what will be created)

```bash
helm install my-2tier-app . --dry-run --debug
```

This shows you **exactly** what Kubernetes resources will be created without actually creating them.

### Step 3: Render templates (see generated YAML)

```bash
helm template my-2tier-app .
```

This outputs the complete YAML after Helm processes the templates.

**Save it to a file for review:**
```bash
helm template my-2tier-app . > rendered-manifests.yaml
```

---

## 🚀 Part 4: Install the Helm Chart

Now let's actually deploy the application!

### Step 1: Install with default values

```bash
cd /home/anataraj/Projects/cka/2-tier-app

helm install my-2tier-app ./2-tier-helm-chart
```

**✅ Expected output:**
```
NAME: my-2tier-app
LAST DEPLOYED: [timestamp]
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

### Step 2: Check the release status

```bash
helm status my-2tier-app
```

### Step 3: Verify Kubernetes resources were created

```bash
# Check all resources
kubectl get all

# Check specific resources
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get pvc
kubectl get secrets
kubectl get configmaps
```

### Step 4: Watch pods until they're running

```bash
kubectl get pods -w
```

**Press Ctrl+C to stop watching**

### Step 5: Check pod logs

```bash
# List pods
kubectl get pods

# Check MySQL logs
kubectl logs <mysql-pod-name>

# Check webapp logs
kubectl logs <webapp-pod-name>
```

### Step 6: Access the application

```bash
# Get the NodePort service
kubectl get svc webapp-service

# Access in your browser
# http://localhost:30080
```

**Or use curl:**
```bash
curl http://localhost:30080
```

---

## 🎨 Part 5: Customize Your Deployment

Let's explore different ways to customize the deployment!

### Method 1: Override values via command line

```bash
# Install with 3 webapp replicas instead of 2
helm install my-app ./2-tier-helm-chart --set webapp.replicas=3

# Install with different port
helm install my-app ./2-tier-helm-chart --set webapp.service.nodePort=30081

# Multiple overrides
helm install my-app ./2-tier-helm-chart \
  --set webapp.replicas=3 \
  --set mysql.auth.rootPassword=mySecretPassword
```

### Method 2: Use a custom values file

Create a custom values file:

```bash
cd /home/anataraj/Projects/cka/2-tier-app

cat > custom-values.yaml << 'EOF'
# Custom configuration for dev environment
mysql:
  replicas: 1
  auth:
    rootPassword: dev-password
    database: devdb
  persistence:
    size: 500Mi

webapp:
  replicas: 1
  service:
    nodePort: 30090
  resources:
    requests:
      memory: 64Mi
      cpu: 50m
EOF
```

Install with custom values:

```bash
helm install dev-app ./2-tier-helm-chart -f custom-values.yaml
```

### Method 3: Create environment-specific values

```bash
# Development environment
cat > values-dev.yaml << 'EOF'
mysql:
  replicas: 1
  persistence:
    size: 500Mi
webapp:
  replicas: 1
  service:
    nodePort: 30090
EOF

# Production environment
cat > values-prod.yaml << 'EOF'
mysql:
  replicas: 1
  persistence:
    size: 10Gi
webapp:
  replicas: 5
  service:
    nodePort: 30080
  resources:
    requests:
      memory: 256Mi
      cpu: 200m
    limits:
      memory: 512Mi
      cpu: 500m
EOF

# Install for dev
helm install dev-app ./2-tier-helm-chart -f values-dev.yaml

# Install for prod (in different namespace)
kubectl create namespace production
helm install prod-app ./2-tier-helm-chart -f values-prod.yaml -n production
```

---

## 🔄 Part 6: Upgrade and Rollback

### Upgrade the application

```bash
# Upgrade with more replicas
helm upgrade my-2tier-app ./2-tier-helm-chart --set webapp.replicas=4

# Verify the upgrade
kubectl get pods
```

### Check release history

```bash
helm history my-2tier-app
```

**Output:**
```
REVISION  UPDATED                   STATUS      CHART           DESCRIPTION
1         Mon Nov 21 10:00:00 2025  superseded  2-tier-app-0.1.0  Install complete
2         Mon Nov 21 10:05:00 2025  deployed    2-tier-app-0.1.0  Upgrade complete
```

### Rollback to previous version

```bash
# Rollback to previous revision
helm rollback my-2tier-app

# Or rollback to specific revision
helm rollback my-2tier-app 1
```

### Verify rollback

```bash
helm history my-2tier-app
kubectl get pods
```

---

## 📦 Part 7: Package and Share Your Chart

### Step 1: Package the chart

```bash
cd /home/anataraj/Projects/cka/2-tier-app

helm package ./2-tier-helm-chart
```

**This creates:** `2-tier-app-0.1.0.tgz`

### Step 2: Verify the package

```bash
ls -lh *.tgz
```

### Step 3: Install from the package

```bash
helm install packaged-app ./2-tier-app-0.1.0.tgz
```

### Step 4: Share with others

You can now share the `.tgz` file with your team!

```bash
# They can install it with:
helm install their-app ./2-tier-app-0.1.0.tgz
```

---

## 🌐 Part 8: Working with Helm Repositories

### Add popular Helm repositories

```bash
# Add Bitnami charts
helm repo add bitnami https://charts.bitnami.com/bitnami

# Add Nginx
helm repo add nginx https://helm.nginx.com/stable

# Add Jetstack (for cert-manager)
helm repo add jetstack https://charts.jetstack.io

# Update repos
helm repo update
```

### List repositories

```bash
helm repo list
```

### Search for charts

```bash
# Search for MySQL charts
helm search repo mysql

# Search for all charts with 'database' in name
helm search repo database

# Search in specific repo
helm search repo bitnami/mysql
```

### Install chart from repository

```bash
# Install MySQL from Bitnami
helm install my-mysql bitnami/mysql

# Install with custom values
helm install my-mysql bitnami/mysql \
  --set auth.rootPassword=secretpassword \
  --set primary.persistence.size=5Gi
```

### View chart information

```bash
# Show chart details
helm show chart bitnami/mysql

# Show default values
helm show values bitnami/mysql

# Show README
helm show readme bitnami/mysql

# Show everything
helm show all bitnami/mysql
```

---

## 🧪 Part 9: Testing and Debugging

### Test the deployment

```bash
# Check if pods are running
kubectl get pods

# Check if services are accessible
kubectl get svc

# Test webapp endpoint
curl http://localhost:30080/api/health

# Test database connectivity from webapp pod
kubectl exec -it <webapp-pod-name> -- env | grep DB_
```

### Debug common issues

#### Issue 1: Pods not starting

```bash
# Check pod status
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

#### Issue 2: Image pull errors

```bash
# For kind cluster, ensure image is loaded
kind load docker-image webapp:latest --name demo-cluster

# Verify images in kind
docker exec -it demo-cluster-control-plane crictl images
```

#### Issue 3: Helm release issues

```bash
# List all releases
helm list

# Get release details
helm get all my-2tier-app

# Get generated manifests
helm get manifest my-2tier-app

# Get values used in release
helm get values my-2tier-app
```

### Use Helm debugging features

```bash
# Dry run with debug
helm install my-app ./2-tier-helm-chart --dry-run --debug

# Template with debug
helm template my-app ./2-tier-helm-chart --debug
```

---

## 🧹 Part 10: Clean Up

### Uninstall a release

```bash
# Uninstall the release
helm uninstall my-2tier-app

# Verify uninstall
helm list
kubectl get all
```

### Uninstall but keep history

```bash
helm uninstall my-2tier-app --keep-history

# View history even after uninstall
helm history my-2tier-app
```

### Clean up all resources

```bash
# Delete all releases in current namespace
helm list --short | xargs -L1 helm uninstall

# Delete namespace (if used)
kubectl delete namespace dev
kubectl delete namespace production
```

### Remove packages

```bash
cd /home/anataraj/Projects/cka/2-tier-app
rm -f *.tgz
```

---

## 📊 Part 11: Advanced Helm Commands

### Get information about releases

```bash
# List all releases in all namespaces
helm list --all-namespaces

# List releases with specific status
helm list --failed
helm list --deployed
helm list --pending

# Get release notes
helm get notes my-2tier-app

# Get all information about release
helm get all my-2tier-app
```

### Manage values

```bash
# Get values used in release
helm get values my-2tier-app

# Get all values (including defaults)
helm get values my-2tier-app --all

# Get values in revision 1
helm get values my-2tier-app --revision 1
```

### Work with dependencies

```bash
# Update chart dependencies
helm dependency update ./2-tier-helm-chart

# List dependencies
helm dependency list ./2-tier-helm-chart
```

### Chart signing and verification (advanced)

```bash
# Package and sign
helm package --sign --key 'mykey' --keyring ~/.gnupg/secring.gpg ./2-tier-helm-chart

# Verify a chart
helm verify ./2-tier-app-0.1.0.tgz
```

---

## 🎓 Part 12: Best Practices

### 1. Always use `--dry-run` before installing

```bash
helm install my-app ./2-tier-helm-chart --dry-run --debug
```

### 2. Use `helm lint` to catch errors

```bash
helm lint ./2-tier-helm-chart
```

### 3. Version your charts properly

Update `Chart.yaml` version when you make changes:
```yaml
version: 0.1.0  # Chart version
appVersion: "1.0"  # Application version
```

### 4. Use meaningful release names

```bash
# Good
helm install my-app-dev ./2-tier-helm-chart
helm install my-app-prod ./2-tier-helm-chart

# Bad
helm install app ./2-tier-helm-chart
helm install test ./2-tier-helm-chart
```

### 5. Use namespaces

```bash
# Create namespace
kubectl create namespace dev

# Install in namespace
helm install my-app ./2-tier-helm-chart -n dev
```

### 6. Document your values

Add comments in `values.yaml`:
```yaml
# Number of webapp replicas (recommended: 2 for prod, 1 for dev)
webapp:
  replicas: 2
```

### 7. Use `--wait` for production deployments

```bash
helm install my-app ./2-tier-helm-chart --wait --timeout 5m
```

### 8. Test before upgrading production

```bash
# Test upgrade in dev first
helm upgrade dev-app ./2-tier-helm-chart -n dev

# Then upgrade production
helm upgrade prod-app ./2-tier-helm-chart -n production
```

---

## 🎯 Quick Reference Commands

### Installation
```bash
helm install <release-name> <chart-path>
helm install my-app ./chart -f values.yaml
helm install my-app ./chart --set key=value
helm install my-app ./chart -n namespace
helm install my-app ./chart --dry-run --debug
```

### Management
```bash
helm list
helm status <release-name>
helm get all <release-name>
helm get values <release-name>
helm get manifest <release-name>
```

### Upgrade & Rollback
```bash
helm upgrade <release-name> <chart-path>
helm upgrade --install <release-name> <chart-path>
helm history <release-name>
helm rollback <release-name> <revision>
```

### Uninstall
```bash
helm uninstall <release-name>
helm uninstall <release-name> --keep-history
```

### Chart Operations
```bash
helm create <chart-name>
helm lint <chart-path>
helm package <chart-path>
helm template <release-name> <chart-path>
```

### Repository Management
```bash
helm repo add <name> <url>
helm repo list
helm repo update
helm repo remove <name>
helm search repo <keyword>
```

---

## 🎉 Congratulations!

You now know how to:
- ✅ Create Helm charts
- ✅ Install and manage releases
- ✅ Customize deployments
- ✅ Upgrade and rollback
- ✅ Package and share charts
- ✅ Work with Helm repositories
- ✅ Debug issues

## 📚 Next Steps

1. **Practice**: Deploy more applications using Helm
2. **Explore**: Browse [Artifact Hub](https://artifacthub.io/) for charts
3. **Advanced**: Learn about Helm hooks, subcharts, and chart dependencies
4. **CI/CD**: Integrate Helm into your deployment pipelines
5. **Share**: Publish your charts to a Helm repository

---

## 🆘 Need Help?

- **Official Docs**: https://helm.sh/docs/
- **Helm Hub**: https://artifacthub.io/
- **Community**: https://helm.sh/community/
- **GitHub**: https://github.com/helm/helm

Happy Helming! 🎉

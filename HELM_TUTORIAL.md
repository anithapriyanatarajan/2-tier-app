# 🎓 Helm Zero-to-Hero Tutorial
## From Beginner to Confident Helm User

---

## 📚 Table of Contents
1. [What is Helm?](#what-is-helm)
2. [Why Do We Need Helm?](#why-do-we-need-helm)
3. [Helm Concepts Explained Simply](#helm-concepts-explained-simply)
4. [Installing Helm](#installing-helm)
5. [Creating Your First Helm Chart](#creating-your-first-helm-chart)
6. [Understanding Helm Chart Structure](#understanding-helm-chart-structure)
7. [Converting Our 2-Tier App to Helm](#converting-our-2-tier-app-to-helm)
8. [Essential Helm Commands](#essential-helm-commands)
9. [Working with Helm Locally](#working-with-helm-locally)
10. [Installing Helm Charts](#installing-helm-charts)
11. [Hands-On Practice](#hands-on-practice)

---

## 🤔 What is Helm?

Think of Helm as the **"App Store" for Kubernetes**. Just like how you install apps on your phone with one click, Helm helps you install complete applications on Kubernetes with one command.

### Simple Analogy
- **Without Helm**: Like building furniture by buying individual screws, wood pieces, and tools separately
- **With Helm**: Like buying IKEA furniture - everything comes packaged together with instructions

---

## 🎯 Why Do We Need Helm?

### The Problem Without Helm

Look at our current 2-tier app. To deploy it, we need to:
```bash
kubectl apply -f mysql-deployment.yaml
kubectl apply -f webapp-deployment.yaml
```

But imagine if we have:
- ✅ 10 different YAML files
- ✅ Multiple environments (dev, staging, production)
- ✅ Different configurations for each environment
- ✅ Need to update values across all files

**This becomes a nightmare! 😰**

### The Solution: Helm

Helm solves this by:
1. **Packaging**: Bundle all YAML files together
2. **Templating**: Use variables instead of hard-coded values
3. **Versioning**: Track changes like Git for your deployments
4. **Reusability**: Use the same chart for different environments
5. **Sharing**: Share charts with others (like Docker Hub for K8s apps)

---

## 🧩 Helm Concepts Explained Simply

### 1. **Chart** 📦
A Helm Chart is like a **recipe box** containing:
- All Kubernetes YAML files
- Configuration values
- Instructions for deployment

**Think of it as**: A zip file with all your K8s configs + templates

### 2. **Values** ⚙️
Values are like **settings** you can customize:
```yaml
# Like choosing pizza toppings
replicas: 2          # How many app copies?
image: mysql:8.0     # Which container image?
service:
  port: 3306         # Which port to use?
```

### 3. **Release** 🚀
A Release is an **installed instance** of a chart:
- Chart is the blueprint
- Release is the actual running app

**Analogy**: Chart = House Plan, Release = Actual House Built

### 4. **Repository** 🏪
A Helm Repository is like an **App Store**:
- Public repos: Anyone can download charts
- Private repos: Only your team can access

### 5. **Templates** 📝
Templates are YAML files with **placeholders**:
```yaml
# Instead of hard-coded values:
replicas: 2

# Templates use variables:
replicas: {{ .Values.replicas }}
```

---

## 📥 Installing Helm

### Step 1: Install Helm CLI

#### On Linux:
```bash
# Download Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

#### On macOS:
```bash
brew install helm
helm version
```

#### On Windows (PowerShell):
```powershell
choco install kubernetes-helm
helm version
```

### Step 2: Verify Helm Works
```bash
# Check if Helm can talk to your cluster
helm list

# Add a popular chart repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Search for a chart
helm search repo mysql
```

**✅ Expected Output:**
```
NAME                 	CHART VERSION	APP VERSION	DESCRIPTION
bitnami/mysql        	9.14.4       	8.0.35     	MySQL is a fast, reliable, scalable...
```

---

## 🏗️ Creating Your First Helm Chart

### Method 1: Start from Scratch (Learning Mode)

```bash
# Navigate to your project
cd /home/anataraj/Projects/cka/2-tier-app

# Create a new Helm chart
helm create my-first-chart

# See what was created
ls -la my-first-chart/
```

**What You'll See:**
```
my-first-chart/
├── Chart.yaml           # Chart metadata (name, version, description)
├── values.yaml          # Default configuration values
├── charts/              # Dependencies (other charts this chart needs)
├── templates/           # Kubernetes YAML templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── _helpers.tpl    # Template helper functions
│   └── tests/          # Test files
└── .helmignore         # Files to ignore (like .gitignore)
```

### Method 2: Convert Existing K8s Files (Our Approach)

We'll convert our existing `k8s/` directory into a Helm chart!

---

## 📖 Understanding Helm Chart Structure

Let's break down each file:

### 1. `Chart.yaml` - The Identity Card
```yaml
apiVersion: v2                    # Helm version (always v2 for Helm 3)
name: 2-tier-app                  # Your chart name
description: A 2-tier web app     # What does it do?
type: application                 # Type: application or library
version: 0.1.0                    # Chart version (update when you change the chart)
appVersion: "1.0"                 # Your app's version
```

**Think of it as**: Your app's birth certificate

### 2. `values.yaml` - The Settings File
```yaml
# This is where you put all configurable values
mysql:
  replicas: 1
  image: mysql:8.0
  rootPassword: rootpassword
  database: keyvaluedb

webapp:
  replicas: 2
  image: webapp:latest
  service:
    type: NodePort
    port: 80
    nodePort: 30080
```

**Think of it as**: The control panel for your app

### 3. `templates/` - The Smart YAML Files
These are your Kubernetes YAML files but with **superpowers** (variables!):

```yaml
# Before (static):
replicas: 2

# After (dynamic):
replicas: {{ .Values.webapp.replicas }}
```

---

## 🔄 Converting Our 2-Tier App to Helm

Let's convert our app step-by-step!

### Step 1: Create the Chart Structure
```bash
cd /home/anataraj/Projects/cka/2-tier-app
mkdir -p 2-tier-helm-chart/templates
cd 2-tier-helm-chart
```

### Step 2: Create Chart.yaml
```bash
cat > Chart.yaml << 'EOF'
apiVersion: v2
name: 2-tier-app
description: A 2-tier Flask web application with MySQL database
type: application
version: 0.1.0
appVersion: "1.0"
keywords:
  - flask
  - mysql
  - 2-tier
maintainers:
  - name: Your Name
    email: your.email@example.com
EOF
```

### Step 3: Create values.yaml
```bash
cat > values.yaml << 'EOF'
# MySQL Configuration
mysql:
  enabled: true
  replicas: 1
  image:
    repository: mysql
    tag: "8.0"
    pullPolicy: IfNotPresent
  
  service:
    type: ClusterIP
    port: 3306
  
  auth:
    rootPassword: rootpassword
    database: keyvaluedb
    username: dbuser
    password: dbpassword
  
  persistence:
    enabled: true
    storageClass: ""
    size: 1Gi
  
  resources:
    requests:
      memory: 256Mi
      cpu: 250m
    limits:
      memory: 512Mi
      cpu: 500m

# Web Application Configuration
webapp:
  enabled: true
  replicas: 2
  image:
    repository: webapp
    tag: latest
    pullPolicy: Never  # For local kind cluster
  
  service:
    type: NodePort
    port: 80
    targetPort: 5000
    nodePort: 30080
  
  resources:
    requests:
      memory: 128Mi
      cpu: 100m
    limits:
      memory: 256Mi
      cpu: 200m
  
  probes:
    liveness:
      enabled: true
      path: /api/health
      initialDelaySeconds: 30
      periodSeconds: 10
    readiness:
      enabled: true
      path: /api/health
      initialDelaySeconds: 10
      periodSeconds: 5

# Global Configuration
nameOverride: ""
fullnameOverride: ""
EOF
```

### Step 4: Create Template Files

Now we convert our YAML files to templates!

---

## 🛠️ Essential Helm Commands

### Basic Commands

#### 1. Install a Chart
```bash
# Install from local chart
helm install my-app ./2-tier-helm-chart

# Install from a repository
helm install my-mysql bitnami/mysql

# Install with custom values
helm install my-app ./2-tier-helm-chart -f custom-values.yaml

# Install and set values via command line
helm install my-app ./2-tier-helm-chart --set mysql.replicas=2
```

#### 2. List Releases
```bash
# List all releases
helm list

# List all releases in all namespaces
helm list --all-namespaces

# List releases in specific namespace
helm list -n production
```

#### 3. Check Status
```bash
# Check release status
helm status my-app

# Get all information about a release
helm get all my-app
```

#### 4. Upgrade a Release
```bash
# Upgrade with new values
helm upgrade my-app ./2-tier-helm-chart

# Upgrade and install if doesn't exist
helm upgrade --install my-app ./2-tier-helm-chart

# Upgrade with specific values
helm upgrade my-app ./2-tier-helm-chart --set webapp.replicas=3
```

#### 5. Rollback
```bash
# See release history
helm history my-app

# Rollback to previous version
helm rollback my-app

# Rollback to specific revision
helm rollback my-app 2
```

#### 6. Uninstall
```bash
# Uninstall a release
helm uninstall my-app

# Uninstall and keep history
helm uninstall my-app --keep-history
```

### Advanced Commands

#### 7. Dry Run (Preview without Installing)
```bash
# See what would be installed
helm install my-app ./2-tier-helm-chart --dry-run --debug

# Template the chart (see generated YAML)
helm template my-app ./2-tier-helm-chart
```

#### 8. Package a Chart
```bash
# Create a .tgz package
helm package ./2-tier-helm-chart

# Creates: 2-tier-app-0.1.0.tgz
```

#### 9. Lint (Check for Errors)
```bash
# Verify chart syntax
helm lint ./2-tier-helm-chart
```

#### 10. Working with Repositories
```bash
# Add a repository
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami

# List repositories
helm repo list

# Update repositories
helm repo update

# Search in repositories
helm search repo mysql

# Remove a repository
helm repo remove bitnami
```

---

## 💻 Working with Helm Locally

### Testing Your Chart Before Deployment

#### 1. Validate Chart Structure
```bash
# Check if chart structure is correct
helm lint ./2-tier-helm-chart
```

**✅ Expected Output:**
```
==> Linting ./2-tier-helm-chart
[INFO] Chart.yaml: icon is recommended
1 chart(s) linted, 0 chart(s) failed
```

#### 2. Render Templates Locally
```bash
# See what YAML will be generated
helm template my-app ./2-tier-helm-chart

# Save output to file
helm template my-app ./2-tier-helm-chart > rendered.yaml

# Render with custom values
helm template my-app ./2-tier-helm-chart -f custom-values.yaml
```

#### 3. Dry Run Installation
```bash
# See what would happen without actually installing
helm install my-app ./2-tier-helm-chart --dry-run --debug
```

#### 4. Test Different Values
```bash
# Create test values file
cat > test-values.yaml << EOF
webapp:
  replicas: 5
mysql:
  auth:
    rootPassword: testpassword
EOF

# Test with these values
helm template my-app ./2-tier-helm-chart -f test-values.yaml
```

---

## 📦 Installing Helm Charts

### Scenario 1: Install Chart from Local Directory

```bash
# Make sure you're in the right directory
cd /home/anataraj/Projects/cka/2-tier-app

# Install the chart
helm install my-2tier-app ./2-tier-helm-chart

# Check if it's running
helm status my-2tier-app
kubectl get pods
```

### Scenario 2: Install Chart from Remote Repository

```bash
# Add the repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Search for charts
helm search repo wordpress

# Install a chart
helm install my-wordpress bitnami/wordpress

# Install with custom values
helm install my-wordpress bitnami/wordpress \
  --set wordpressUsername=admin \
  --set wordpressPassword=password123
```

### Scenario 3: Install from Packaged Chart (.tgz)

```bash
# First, package your chart
helm package ./2-tier-helm-chart

# This creates: 2-tier-app-0.1.0.tgz

# Install from the package
helm install my-app ./2-tier-app-0.1.0.tgz

# Or share the .tgz file with others!
```

### Scenario 4: Install in Different Namespaces

```bash
# Create namespace
kubectl create namespace dev

# Install in specific namespace
helm install my-app ./2-tier-helm-chart -n dev

# List releases in that namespace
helm list -n dev
```

### Scenario 5: Install with Different Environments

```bash
# Create values for different environments
cat > values-dev.yaml << EOF
webapp:
  replicas: 1
mysql:
  persistence:
    size: 500Mi
EOF

cat > values-prod.yaml << EOF
webapp:
  replicas: 3
mysql:
  persistence:
    size: 10Gi
EOF

# Install for dev
helm install my-app ./2-tier-helm-chart -f values-dev.yaml -n dev

# Install for prod
helm install my-app ./2-tier-helm-chart -f values-prod.yaml -n prod
```

---

## 🎮 Hands-On Practice

### Exercise 1: Your First Helm Install

```bash
# Step 1: Ensure kind cluster is running
kind get clusters

# Step 2: Install from local chart
cd /home/anataraj/Projects/cka/2-tier-app
helm install demo-app ./2-tier-helm-chart

# Step 3: Verify installation
helm list
kubectl get all

# Step 4: Check the app
kubectl get svc webapp-service
# Access at: http://localhost:30080

# Step 5: Clean up
helm uninstall demo-app
```

### Exercise 2: Customize Values

```bash
# Create custom values
cat > my-values.yaml << EOF
webapp:
  replicas: 3
  service:
    nodePort: 30081
mysql:
  replicas: 1
EOF

# Install with custom values
helm install custom-app ./2-tier-helm-chart -f my-values.yaml

# Verify replicas
kubectl get pods

# Clean up
helm uninstall custom-app
```

### Exercise 3: Upgrade and Rollback

```bash
# Install initial version
helm install test-app ./2-tier-helm-chart

# Upgrade with more replicas
helm upgrade test-app ./2-tier-helm-chart --set webapp.replicas=4

# Check history
helm history test-app

# Rollback to previous version
helm rollback test-app

# Verify rollback
helm history test-app

# Clean up
helm uninstall test-app
```

### Exercise 4: Install from Public Repository

```bash
# Add nginx repository
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

# Search for nginx
helm search repo nginx

# Install nginx ingress controller
helm install my-nginx nginx-stable/nginx-ingress

# Check what was installed
helm status my-nginx
kubectl get all

# Uninstall when done
helm uninstall my-nginx
```

---

## 🎓 Command Cheat Sheet

### Quick Reference

| Task | Command |
|------|---------|
| Install chart | `helm install NAME ./chart` |
| Install from repo | `helm install NAME repo/chart` |
| Install with values | `helm install NAME ./chart -f values.yaml` |
| List releases | `helm list` |
| Check status | `helm status NAME` |
| Upgrade | `helm upgrade NAME ./chart` |
| Rollback | `helm rollback NAME` |
| Uninstall | `helm uninstall NAME` |
| Dry run | `helm install NAME ./chart --dry-run` |
| Render templates | `helm template NAME ./chart` |
| Package chart | `helm package ./chart` |
| Lint chart | `helm lint ./chart` |
| Add repo | `helm repo add NAME URL` |
| Update repos | `helm repo update` |
| Search repos | `helm search repo KEYWORD` |

---

## 🚀 Next Steps

1. **Practice**: Convert more K8s apps to Helm charts
2. **Explore**: Browse charts at [Artifact Hub](https://artifacthub.io/)
3. **Advanced**: Learn about Helm hooks, dependencies, and subcharts
4. **Share**: Create and share your own charts
5. **Automate**: Use Helm in CI/CD pipelines

---

## 📚 Additional Resources

- **Official Docs**: https://helm.sh/docs/
- **Chart Best Practices**: https://helm.sh/docs/chart_best_practices/
- **Public Charts**: https://artifacthub.io/
- **Helm GitHub**: https://github.com/helm/helm

---

## ❓ Common Questions

**Q: Helm 2 vs Helm 3?**
A: Always use Helm 3 (current version). It's simpler and doesn't need Tiller.

**Q: When should I use Helm?**
A: When you have multiple K8s resources, need different environments, or want to share/reuse deployments.

**Q: Can I use Helm with existing YAML files?**
A: Yes! Just move them to templates/ and add {{ .Values.* }} placeholders.

**Q: How do I debug Helm issues?**
A: Use `--dry-run --debug` flags to see what's happening.

---

**🎉 Congratulations! You've completed the Helm Zero-to-Hero tutorial!**

Now let's build your actual Helm chart for the 2-tier app! 🚀

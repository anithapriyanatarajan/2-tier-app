# 🎓 Helm Zero-to-Hero: Complete Learning Path

Welcome to your complete Helm learning journey! This document guides you through everything you need to know about Helm, from absolute beginner to confident user.

---

## 📚 Learning Path Overview

```
1. Understand What & Why
   └─> HELM_TUTORIAL.md (Theory & Concepts)
        ↓
2. Explore the Helm Chart
   └─> 2-tier-helm-chart/README.md (Chart Documentation)
        ↓
3. Hands-On Practice
   └─> HANDS_ON_GUIDE.md (Step-by-Step Commands)
        ↓
4. Quick Deployment
   └─> helm-quickstart.sh (Automated Script)
```

---

## 📖 Step-by-Step Learning Guide

### 🎯 Phase 1: Understanding Helm (30 minutes)
**Read: `HELM_TUTORIAL.md`**

**What you'll learn:**
- ✅ What is Helm and why we need it
- ✅ Helm concepts (Charts, Values, Releases, Repositories)
- ✅ How Helm solves Kubernetes deployment challenges
- ✅ Helm terminology explained with simple analogies
- ✅ Basic vs Advanced Helm commands

**Key Takeaways:**
- Helm is like an "App Store" for Kubernetes
- Charts are packages of Kubernetes resources
- Values make charts customizable and reusable
- Templates turn static YAML into dynamic configurations

**Action Items:**
1. Read through the tutorial
2. Install Helm on your system
3. Add a public Helm repository
4. Search for a chart (e.g., `helm search repo nginx`)

---

### 🔍 Phase 2: Exploring Your First Helm Chart (20 minutes)
**Read: `2-tier-helm-chart/README.md`**

**What you'll learn:**
- ✅ Anatomy of a Helm chart
- ✅ Structure of Chart.yaml and values.yaml
- ✅ How templates work with Go templating
- ✅ Understanding helper functions
- ✅ Chart configuration options

**Key Files to Examine:**

1. **Chart.yaml** - The chart's identity
   ```bash
   cat 2-tier-helm-chart/Chart.yaml
   ```

2. **values.yaml** - Default configuration
   ```bash
   cat 2-tier-helm-chart/values.yaml
   ```

3. **templates/** - Kubernetes manifests with placeholders
   ```bash
   ls -la 2-tier-helm-chart/templates/
   ```

**Action Items:**
1. Navigate to `2-tier-helm-chart/`
2. Examine Chart.yaml - note the version, name, description
3. Study values.yaml - see how configurations are structured
4. Look at one template (e.g., mysql-deployment.yaml)
5. Notice the `{{ .Values.* }}` placeholders

---

### 🛠️ Phase 3: Hands-On Practice (60 minutes)
**Follow: `HANDS_ON_GUIDE.md`**

**What you'll do:**

#### Exercise 1: Validate and Preview (10 mins)
```bash
cd /home/anataraj/Projects/cka/2-tier-app

# Lint the chart
helm lint ./2-tier-helm-chart

# Dry run (preview without installing)
helm install test-app ./2-tier-helm-chart --dry-run --debug

# Render templates
helm template test-app ./2-tier-helm-chart
```

#### Exercise 2: Install Your First Release (15 mins)
```bash
# Make sure webapp image is built
cd app
docker build -t webapp:latest .
kind load docker-image webapp:latest --name demo-cluster

# Install the chart
cd ..
helm install my-first-app ./2-tier-helm-chart

# Check status
helm status my-first-app
kubectl get all
```

#### Exercise 3: Customize and Upgrade (15 mins)
```bash
# Upgrade with different values
helm upgrade my-first-app ./2-tier-helm-chart \
  --set webapp.replicas=3

# Check the change
kubectl get pods

# View history
helm history my-first-app
```

#### Exercise 4: Work with Custom Values (10 mins)
```bash
# Create custom values file
cat > my-values.yaml << EOF
webapp:
  replicas: 4
  service:
    nodePort: 30081
mysql:
  persistence:
    size: 2Gi
EOF

# Install with custom values
helm install custom-app ./2-tier-helm-chart -f my-values.yaml
```

#### Exercise 5: Rollback (5 mins)
```bash
# Rollback to previous version
helm rollback my-first-app

# Verify
kubectl get pods
```

#### Exercise 6: Package and Share (5 mins)
```bash
# Package the chart
helm package ./2-tier-helm-chart

# You now have: 2-tier-app-0.1.0.tgz
ls -lh *.tgz
```

**Action Items:**
1. Complete all 6 exercises in order
2. Experiment with different values
3. Break something intentionally and fix it
4. Access the application in your browser

---

### ⚡ Phase 4: Quick Deployment (10 minutes)
**Use: `helm-quickstart.sh`**

**What it does:**
- Automates the entire deployment process
- Checks prerequisites
- Builds and loads Docker image
- Validates chart
- Installs release
- Shows status

**How to use:**

```bash
# Interactive menu
./helm-quickstart.sh

# Or full automated setup
./helm-quickstart.sh --full
```

**Menu Options:**
1. Check prerequisites
2. Build and load webapp image
3. Validate Helm chart
4. Install Helm chart
5. Show deployment status
6. Uninstall Helm chart
7. Full setup (all steps)
8. Exit

**Action Items:**
1. Run the script in interactive mode
2. Try the full setup option
3. Verify everything works
4. Use it for quick testing

---

## 🎓 Learning Milestones

### Beginner (You are here! 🌟)
- [x] Understand what Helm is
- [x] Know Helm terminology
- [x] Can install a Helm chart
- [x] Can view releases
- [x] Can uninstall a release

### Intermediate (Next Level 🚀)
- [ ] Customize charts with values files
- [ ] Upgrade and rollback releases
- [ ] Package and share charts
- [ ] Work with Helm repositories
- [ ] Create basic charts from scratch

### Advanced (Expert Level 💪)
- [ ] Use Helm hooks
- [ ] Manage chart dependencies
- [ ] Implement conditional logic in templates
- [ ] Create helper functions
- [ ] Set up Helm in CI/CD pipelines

---

## 📋 Command Cheat Sheet

### Essential Commands (Memorize These!)

```bash
# Install
helm install <name> <chart>

# List releases
helm list

# Status
helm status <name>

# Upgrade
helm upgrade <name> <chart>

# Rollback
helm rollback <name>

# Uninstall
helm uninstall <name>

# Package
helm package <chart>

# Lint
helm lint <chart>
```

### Useful Commands (Know These!)

```bash
# Dry run
helm install <name> <chart> --dry-run --debug

# Custom values
helm install <name> <chart> -f values.yaml

# Set values
helm install <name> <chart> --set key=value

# History
helm history <name>

# Get values
helm get values <name>

# Template
helm template <name> <chart>
```

### Repository Commands (Use Often!)

```bash
# Add repo
helm repo add <name> <url>

# Update repos
helm repo update

# Search
helm search repo <keyword>

# List repos
helm repo list
```

---

## 🎯 Practice Exercises

### Exercise 1: Deploy Different Environments
Create and deploy dev, staging, and prod versions of the app.

```bash
# Dev (minimal resources)
cat > values-dev.yaml << EOF
mysql:
  persistence:
    size: 500Mi
webapp:
  replicas: 1
EOF

kubectl create namespace dev
helm install dev-app ./2-tier-helm-chart -f values-dev.yaml -n dev

# Prod (more resources)
cat > values-prod.yaml << EOF
mysql:
  persistence:
    size: 10Gi
webapp:
  replicas: 5
EOF

kubectl create namespace prod
helm install prod-app ./2-tier-helm-chart -f values-prod.yaml -n prod
```

### Exercise 2: Upgrade Strategy
Practice upgrading with zero downtime.

```bash
# Install v1
helm install my-app ./2-tier-helm-chart --set webapp.replicas=2

# Upgrade to v2 with more replicas
helm upgrade my-app ./2-tier-helm-chart --set webapp.replicas=4

# Monitor during upgrade
kubectl get pods -w
```

### Exercise 3: Troubleshooting
Intentionally break something and fix it.

```bash
# Install with wrong image
helm install broken-app ./2-tier-helm-chart \
  --set webapp.image.repository=nonexistent

# Debug
kubectl get pods
kubectl describe pod <pod-name>

# Fix with upgrade
helm upgrade broken-app ./2-tier-helm-chart \
  --set webapp.image.repository=webapp
```

### Exercise 4: Package and Share
Create a package and install from it.

```bash
# Package the chart
helm package ./2-tier-helm-chart

# Install from package
helm install packaged-app ./2-tier-app-0.1.0.tgz

# Verify
helm list
```

---

## 🔍 Deep Dive Topics

### Understanding Templates

Templates use Go templating language:

```yaml
# Static value
replicas: 2

# Template value
replicas: {{ .Values.webapp.replicas }}

# With default
replicas: {{ .Values.webapp.replicas | default 2 }}

# Conditional
{{- if .Values.webapp.enabled }}
# ... deploy webapp
{{- end }}
```

### Helper Functions

Located in `_helpers.tpl`:

```yaml
{{/* Generate name */}}
{{- define "2-tier-app.name" -}}
{{- default .Chart.Name .Values.nameOverride }}
{{- end }}

# Usage in templates:
name: {{ include "2-tier-app.name" . }}
```

### Values Hierarchy

Values can be overridden:

```
1. values.yaml (defaults)
2. Custom values file (-f custom.yaml)
3. Command line (--set key=value)
```

---

## 🌐 Working with Public Charts

### Popular Helm Repositories

```bash
# Bitnami (most popular)
helm repo add bitnami https://charts.bitnami.com/bitnami

# Stable charts
helm repo add stable https://charts.helm.sh/stable

# NGINX
helm repo add nginx https://helm.nginx.com/stable

# Update all repos
helm repo update
```

### Installing Public Charts

```bash
# Install MySQL from Bitnami
helm install my-mysql bitnami/mysql

# Install with custom values
helm install my-mysql bitnami/mysql \
  --set auth.rootPassword=mypassword \
  --set primary.persistence.size=5Gi

# See available values
helm show values bitnami/mysql
```

---

## 📊 Best Practices

### 1. Version Control
- Always version your charts (Chart.yaml)
- Tag releases in Git
- Keep values files in Git

### 2. Security
- Don't hardcode secrets in values.yaml
- Use Kubernetes Secrets or external secret managers
- Scan images for vulnerabilities

### 3. Testing
- Always use `--dry-run` first
- Test in dev before prod
- Use `helm lint` before packaging

### 4. Documentation
- Document all values in values.yaml
- Include README.md in charts
- Add comments in templates

### 5. Naming
- Use meaningful release names
- Follow naming conventions
- Use namespaces

---

## 🆘 Troubleshooting Guide

### Issue: Chart Won't Install

```bash
# Check syntax
helm lint ./chart

# Dry run to see errors
helm install test ./chart --dry-run --debug

# Check values
helm template test ./chart
```

### Issue: Pods Not Starting

```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Issue: Can't Access Application

```bash
# Check service
kubectl get svc

# Check if service is exposed
kubectl describe svc <service-name>

# Port forward for testing
kubectl port-forward svc/<service-name> 8080:80
```

### Issue: Upgrade Failed

```bash
# Check release status
helm status <release>

# View history
helm history <release>

# Rollback
helm rollback <release>
```

---

## 📚 Additional Resources

### Official Documentation
- [Helm Docs](https://helm.sh/docs/)
- [Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)

### Chart Repositories
- [Artifact Hub](https://artifacthub.io/) - Search all public charts
- [Bitnami Charts](https://github.com/bitnami/charts)
- [Helm Stable](https://github.com/helm/charts)

### Community
- [Helm GitHub](https://github.com/helm/helm)
- [Helm Slack](https://slack.k8s.io/) - #helm-users channel
- [Stack Overflow](https://stackoverflow.com/questions/tagged/helm)

### Tutorials
- [Helm Getting Started](https://helm.sh/docs/chart_template_guide/getting_started/)
- [Official Examples](https://github.com/helm/examples)

---

## 🎉 Congratulations!

You now have everything you need to:

✅ **Understand** Helm concepts and terminology  
✅ **Install** and manage Helm releases  
✅ **Customize** deployments with values  
✅ **Create** your own Helm charts  
✅ **Package** and share charts  
✅ **Troubleshoot** common issues  
✅ **Use** public Helm repositories  
✅ **Deploy** in different environments  

---

## 🚀 Next Steps

1. **Practice Daily**: Use Helm for all your K8s deployments
2. **Explore Charts**: Browse [Artifact Hub](https://artifacthub.io/)
3. **Contribute**: Share your charts with the community
4. **Advanced Topics**: 
   - Helm hooks
   - Chart dependencies
   - Helm plugins
   - Helm in CI/CD
5. **Stay Updated**: Follow Helm releases and blog posts

---

## 📞 Quick Help

| Need | Look Here |
|------|-----------|
| Theory & Concepts | `HELM_TUTORIAL.md` |
| Chart Documentation | `2-tier-helm-chart/README.md` |
| Step-by-Step Commands | `HANDS_ON_GUIDE.md` |
| Quick Deployment | `./helm-quickstart.sh` |
| This Summary | `HELM_LEARNING_PATH.md` (you are here) |

---

**Happy Learning and Happy Helming! 🎉**

Remember: The best way to learn Helm is by doing. Practice, experiment, break things, and fix them. That's how you become a Helm expert!

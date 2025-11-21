# 🚀 Helm Quick Reference Card

**Print this page for quick access to essential commands and concepts!**

---

## 📖 What is Helm?

Helm is a **package manager for Kubernetes** - like apt/yum for Linux or npm for Node.js.

**Key Benefit**: Deploy complex applications with one command instead of managing dozens of YAML files.

---

## 🎯 Core Concepts (30 seconds)

| Concept | What It Is | Analogy |
|---------|-----------|---------|
| **Chart** | Package of K8s resources | Recipe or blueprint |
| **Values** | Configuration options | Settings or preferences |
| **Release** | Installed instance of a chart | Running application |
| **Repository** | Collection of charts | App Store |
| **Template** | YAML with placeholders | Form with blanks to fill |

---

## ⚡ Essential Commands

### Installation & Management
```bash
# Install a chart
helm install <name> <chart>

# Install with custom values
helm install <name> <chart> -f values.yaml

# Install with command-line overrides
helm install <name> <chart> --set key=value

# List all releases
helm list

# Check release status
helm status <name>

# Upgrade a release
helm upgrade <name> <chart>

# Rollback to previous version
helm rollback <name>

# Uninstall a release
helm uninstall <name>
```

### Testing & Debugging
```bash
# Dry run (preview without installing)
helm install <name> <chart> --dry-run --debug

# Render templates locally
helm template <name> <chart>

# Validate chart
helm lint <chart>

# View history
helm history <name>
```

### Repository Management
```bash
# Add repository
helm repo add <name> <url>

# Update repositories
helm repo update

# List repositories
helm repo list

# Search for charts
helm search repo <keyword>

# Show chart info
helm show chart <chart>
helm show values <chart>
```

### Chart Development
```bash
# Create new chart
helm create <name>

# Package chart
helm package <chart>

# Get release values
helm get values <name>

# Get deployed manifests
helm get manifest <name>
```

---

## 📂 Chart Structure

```
my-chart/
├── Chart.yaml          # Chart metadata (name, version)
├── values.yaml         # Default configuration values
├── charts/             # Chart dependencies
├── templates/          # Kubernetes YAML templates
│   ├── _helpers.tpl   # Reusable template functions
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ...
└── .helmignore        # Files to exclude
```

---

## 🎨 Template Syntax

```yaml
# Simple value
replicas: {{ .Values.replicas }}

# Nested value
image: {{ .Values.image.repository }}:{{ .Values.image.tag }}

# With default
replicas: {{ .Values.replicas | default 2 }}

# Conditional
{{- if .Values.enabled }}
enabled: true
{{- end }}

# Loop
{{- range .Values.items }}
- {{ . }}
{{- end }}

# Include template
{{ include "chart.name" . }}

# Built-in values
{{ .Chart.Name }}      # Chart name
{{ .Release.Name }}    # Release name
{{ .Values.key }}      # Custom value
```

---

## 🔄 Release Lifecycle

```
1. INSTALL    → helm install myapp ./chart
2. DEPLOYED   → App is running (Revision 1)
3. UPGRADE    → helm upgrade myapp ./chart
4. DEPLOYED   → App updated (Revision 2)
5. ROLLBACK   → helm rollback myapp
6. DEPLOYED   → Back to Revision 1 (creates Revision 3)
7. UNINSTALL  → helm uninstall myapp
```

---

## ⚙️ Values Precedence (Highest to Lowest)

```
1. --set flags             (helm install --set key=value)
2. -f custom.yaml          (helm install -f values.yaml)
3. values.yaml in chart    (default values)
```

---

## 🌐 Popular Public Repositories

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

---

## 🐛 Common Troubleshooting

### Issue: Chart won't install
```bash
helm lint ./chart              # Check for errors
helm install test ./chart --dry-run --debug
```

### Issue: Pods not starting
```bash
kubectl get pods               # Check status
kubectl describe pod <name>    # See events
kubectl logs <name>            # Check logs
```

### Issue: Need to see what's deployed
```bash
helm get manifest <release>    # See K8s YAML
helm get values <release>      # See values used
```

### Issue: Wrong values applied
```bash
helm get values <release> --all    # See all values
helm upgrade <release> ./chart --set key=correctvalue
```

---

## 🎯 Quick Workflow: Our 2-Tier App

```bash
# 1. Build image
cd app
docker build -t webapp:latest .

# 2. Load to kind
kind load docker-image webapp:latest --name demo-cluster

# 3. Install chart
cd ..
helm install my-app ./2-tier-helm-chart

# 4. Check status
helm status my-app
kubectl get pods

# 5. Access app
open http://localhost:30080

# 6. Upgrade (more replicas)
helm upgrade my-app ./2-tier-helm-chart --set webapp.replicas=5

# 7. Rollback if needed
helm rollback my-app

# 8. Clean up
helm uninstall my-app
```

---

## 📋 Best Practices Checklist

- [ ] Always use `--dry-run` before installing
- [ ] Use `helm lint` to validate charts
- [ ] Version your charts (Chart.yaml)
- [ ] Document values in values.yaml
- [ ] Use meaningful release names
- [ ] Test in dev before prod
- [ ] Use namespaces for isolation
- [ ] Don't hardcode secrets in values
- [ ] Use `--wait` for production deployments
- [ ] Keep chart versions and app versions separate

---

## 🎓 Learning Resources in This Repo

| Document | Purpose | Time |
|----------|---------|------|
| **HELM_ZERO_TO_HERO.md** | Start here - Overview | 15 min |
| **HELM_TUTORIAL.md** | Complete theory guide | 30 min |
| **HELM_VISUAL_GUIDE.md** | Diagrams & visuals | 20 min |
| **HANDS_ON_GUIDE.md** | Practical exercises | 60 min |
| **HELM_LEARNING_PATH.md** | Complete roadmap | 45 min |
| **./helm-quickstart.sh** | Automated setup | 5 min |

---

## 💡 Quick Tips

1. **Start Simple**: Install a public chart first (e.g., `helm install my-nginx bitnami/nginx`)
2. **Use Dry Run**: Always preview with `--dry-run --debug`
3. **Check Values**: Use `helm show values <chart>` to see options
4. **Template First**: Use `helm template` to see generated YAML
5. **Keep History**: Use `helm history` to track changes
6. **Read Errors**: Helm error messages are helpful - read them!
7. **Use Namespaces**: Isolate environments with `-n namespace`
8. **Version Control**: Keep your charts and values in Git

---

## 🔍 Common Use Cases

### Deploy from local chart
```bash
helm install myapp ./my-chart
```

### Deploy from repository
```bash
helm install mydb bitnami/mysql
```

### Deploy with custom values
```bash
helm install myapp ./chart -f prod-values.yaml
```

### Deploy to specific namespace
```bash
helm install myapp ./chart -n production
```

### Upgrade with new values
```bash
helm upgrade myapp ./chart --set replicas=10
```

### Rollback to specific revision
```bash
helm rollback myapp 3
```

### Package and share
```bash
helm package ./my-chart
# Share the .tgz file
```

---

## 🆘 Emergency Commands

```bash
# See all releases
helm list --all-namespaces

# Check what's wrong
kubectl get pods
kubectl describe pod <name>
kubectl logs <name>

# Emergency rollback
helm rollback <release>

# Nuclear option (delete everything)
helm uninstall <release>
kubectl delete all --all
```

---

## 🎯 Our 2-Tier App Values

```yaml
# Quick customization examples
webapp:
  replicas: 2          # Change to 5 for more capacity
  service:
    nodePort: 30080    # Change to 30081 for different port

mysql:
  persistence:
    size: 1Gi          # Change to 10Gi for production
  auth:
    rootPassword: rootpassword  # CHANGE THIS!
```

---

## 🚀 One-Liners for Common Tasks

```bash
# Quick install
helm install my-app ./2-tier-helm-chart

# Quick upgrade with more replicas
helm upgrade my-app ./2-tier-helm-chart --set webapp.replicas=5

# Quick test without installing
helm template test ./2-tier-helm-chart | kubectl apply --dry-run=client -f -

# Quick check what's deployed
helm get all my-app

# Quick rollback
helm rollback my-app

# Quick uninstall
helm uninstall my-app
```

---

## 📞 Get Help

```bash
# General help
helm help

# Command-specific help
helm install --help
helm upgrade --help

# Our documentation
cat HELM_TUTORIAL.md          # Theory
cat HANDS_ON_GUIDE.md         # Practice
cat HELM_VISUAL_GUIDE.md      # Visuals
```

---

## ✅ Quick Verification

After installation, verify with:
```bash
helm list                      # Should show your release
helm status <release>          # Should say "deployed"
kubectl get pods               # Should show running pods
kubectl get svc                # Should show services
curl http://localhost:30080    # Should return web page
```

---

**Print this card and keep it handy! 📝**

**For full tutorials, see the complete documentation in the repo.**

---

*Last Updated: November 21, 2025*  
*Version: 1.0.0*

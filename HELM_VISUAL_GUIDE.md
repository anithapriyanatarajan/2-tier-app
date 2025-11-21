# 🎨 Helm Visual Guide: Concepts in Diagrams

Visual representations to help you understand Helm concepts better!

---

## 📦 What is Helm?

```
┌─────────────────────────────────────────────────────────────┐
│                     Without Helm 😓                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  kubectl apply -f deployment.yaml                           │
│  kubectl apply -f service.yaml                              │
│  kubectl apply -f configmap.yaml                            │
│  kubectl apply -f secret.yaml                               │
│  kubectl apply -f pvc.yaml                                  │
│  kubectl apply -f ingress.yaml                              │
│                                                              │
│  ❌ Many files to manage                                     │
│  ❌ Hard to track what's deployed                           │
│  ❌ Difficult to update all at once                         │
│  ❌ No version control of deployments                       │
│  ❌ Can't easily share with others                          │
└─────────────────────────────────────────────────────────────┘

                            ⬇️

┌─────────────────────────────────────────────────────────────┐
│                      With Helm 🎉                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  helm install my-app ./my-chart                             │
│                                                              │
│  ✅ Single command                                           │
│  ✅ All resources deployed together                         │
│  ✅ Easy to upgrade/rollback                                │
│  ✅ Version controlled                                      │
│  ✅ Shareable as package                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Helm Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                        Helm Architecture                        │
└────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │   Helm CLI   │  ← Your computer (where you run commands)
    │   (Client)   │
    └──────┬───────┘
           │
           │ helm install my-app ./chart
           │
           ▼
    ┌──────────────┐
    │  Helm Chart  │  ← Package of K8s resources
    │  📦          │     (templates + values)
    └──────┬───────┘
           │
           │ Processes templates + values
           │
           ▼
    ┌──────────────────────────────────┐
    │   Kubernetes Manifests (YAML)    │  ← Generated K8s resources
    │                                   │
    │   • Deployment                    │
    │   • Service                       │
    │   • ConfigMap                     │
    │   • Secret                        │
    └──────┬───────────────────────────┘
           │
           │ kubectl apply
           │
           ▼
    ┌─────────────────────────────────────┐
    │      Kubernetes Cluster             │  ← Your cluster
    │                                      │
    │   ┌──────┐  ┌──────┐  ┌──────┐    │
    │   │ Pod  │  │ Pod  │  │ Pod  │    │
    │   └──────┘  └──────┘  └──────┘    │
    │                                      │
    └─────────────────────────────────────┘
           │
           │ Track as "Release"
           │
           ▼
    ┌──────────────┐
    │   Release    │  ← Running instance
    │  "my-app"    │     (stored in cluster)
    └──────────────┘
```

---

## 📂 Helm Chart Structure

```
my-chart/
│
├── Chart.yaml              📄 Chart Metadata
│   ├─ name: my-chart           (Who am I?)
│   ├─ version: 0.1.0           (Chart version)
│   ├─ appVersion: "1.0"        (App version)
│   └─ description: ...         (What do I do?)
│
├── values.yaml             ⚙️  Default Configuration
│   ├─ replicas: 2              (How many pods?)
│   ├─ image: nginx             (Which image?)
│   ├─ service:                 (Service settings)
│   │   ├─ type: NodePort
│   │   └─ port: 80
│   └─ resources: ...           (CPU/Memory limits)
│
├── charts/                 📦 Dependencies
│   └── (other charts)          (Charts this chart needs)
│
├── templates/              📝 Kubernetes Templates
│   │
│   ├── _helpers.tpl        🔧 Helper Functions
│   │   └─ Reusable template snippets
│   │
│   ├── deployment.yaml     🚀 Deployment Template
│   │   ├─ replicas: {{ .Values.replicas }}
│   │   └─ image: {{ .Values.image }}
│   │
│   ├── service.yaml        🌐 Service Template
│   │   ├─ type: {{ .Values.service.type }}
│   │   └─ port: {{ .Values.service.port }}
│   │
│   ├── configmap.yaml      ⚙️  ConfigMap Template
│   ├── secret.yaml         🔐 Secret Template
│   └── NOTES.txt           📋 Post-install message
│
└── .helmignore             🚫 Ignore Files
    └─ Files to exclude from package
```

---

## 🎯 How Helm Templates Work

```
┌────────────────────────────────────────────────────────────┐
│                Template + Values = YAML                     │
└────────────────────────────────────────────────────────────┘

Step 1: Template (deployment.yaml)
┌───────────────────────────────────┐
│ apiVersion: apps/v1               │
│ kind: Deployment                  │
│ metadata:                         │
│   name: {{ .Values.name }}        │ ← Placeholder
│ spec:                             │
│   replicas: {{ .Values.replicas }}│ ← Placeholder
│   template:                       │
│     spec:                         │
│       containers:                 │
│       - name: app                 │
│         image: {{ .Values.image }}│ ← Placeholder
└───────────────────────────────────┘

                  +

Step 2: Values (values.yaml)
┌───────────────────────────────────┐
│ name: my-app                      │
│ replicas: 3                       │
│ image: nginx:1.21                 │
└───────────────────────────────────┘

                  ⬇️
            Helm Processes

Step 3: Final YAML
┌───────────────────────────────────┐
│ apiVersion: apps/v1               │
│ kind: Deployment                  │
│ metadata:                         │
│   name: my-app                    │ ← Filled in!
│ spec:                             │
│   replicas: 3                     │ ← Filled in!
│   template:                       │
│     spec:                         │
│       containers:                 │
│       - name: app                 │
│         image: nginx:1.21         │ ← Filled in!
└───────────────────────────────────┘
```

---

## 🔄 Helm Release Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                   Release Lifecycle                          │
└─────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │   Chart     │  📦 Package (blueprint)
    └──────┬──────┘
           │
           │ helm install my-app ./chart
           ▼
    ┌─────────────┐
    │  Release    │  🚀 Revision 1 (DEPLOYED)
    │  "my-app"   │     Your app is running!
    │  Rev: 1     │
    └──────┬──────┘
           │
           │ helm upgrade my-app ./chart --set replicas=5
           ▼
    ┌─────────────┐
    │  Release    │  🔄 Revision 2 (DEPLOYED)
    │  "my-app"   │     Updated with new values
    │  Rev: 2     │     Rev 1 is now SUPERSEDED
    └──────┬──────┘
           │
           │ helm upgrade my-app ./chart --set image=v2
           ▼
    ┌─────────────┐
    │  Release    │  🔄 Revision 3 (DEPLOYED)
    │  "my-app"   │     Updated again
    │  Rev: 3     │     Rev 2 is now SUPERSEDED
    └──────┬──────┘
           │
           │ Oh no! Bug in v2! 
           │ helm rollback my-app 2
           ▼
    ┌─────────────┐
    │  Release    │  ⏪ Revision 4 (DEPLOYED)
    │  "my-app"   │     Rolled back to Rev 2 config
    │  Rev: 4     │     (Creates new revision!)
    └──────┬──────┘
           │
           │ helm uninstall my-app
           ▼
    ┌─────────────┐
    │  Release    │  🗑️  UNINSTALLED
    │  "my-app"   │     Resources removed
    │  (deleted)  │     History can be kept with --keep-history
    └─────────────┘


History at any time:
┌────────────────────────────────────────┐
│ $ helm history my-app                  │
│                                        │
│ REV  STATUS       CHART      DESC      │
│ 1    SUPERSEDED   v0.1.0    Install   │
│ 2    SUPERSEDED   v0.1.0    Upgrade   │
│ 3    SUPERSEDED   v0.1.0    Upgrade   │
│ 4    DEPLOYED     v0.1.0    Rollback  │
└────────────────────────────────────────┘
```

---

## 🌐 Helm Repositories

```
┌────────────────────────────────────────────────────────────┐
│                    Helm Repository Flow                     │
└────────────────────────────────────────────────────────────┘

    ┌──────────────────────────────────────┐
    │   Public Helm Repositories           │
    │                                       │
    │  • Bitnami (charts.bitnami.com)      │
    │  • Helm Stable (charts.helm.sh)      │
    │  • NGINX (helm.nginx.com)            │
    │  • Your Company Repo                 │
    └──────────────┬───────────────────────┘
                   │
                   │ helm repo add bitnami https://charts.bitnami.com
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │      Your Local Helm Client          │
    │                                       │
    │  Known Repositories:                 │
    │  • bitnami                           │
    │  • stable                            │
    │  • nginx                             │
    └──────────────┬───────────────────────┘
                   │
                   │ helm search repo mysql
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │         Search Results               │
    │                                       │
    │  NAME              VERSION           │
    │  bitnami/mysql     9.14.4            │
    │  stable/mysql      1.6.9             │
    └──────────────┬───────────────────────┘
                   │
                   │ helm install my-db bitnami/mysql
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │     Chart Downloaded & Installed     │
    │                                       │
    │     Running in your cluster!         │
    └──────────────────────────────────────┘
```

---

## 🎨 Values Precedence

```
┌────────────────────────────────────────────────────────────┐
│              Values Precedence (Priority)                   │
└────────────────────────────────────────────────────────────┘

    Highest Priority ⬆️
    ┌─────────────────────────────────┐
    │  Command Line --set             │  --set replicas=10
    │  --set key=value                │  (Overrides everything)
    └─────────────────────────────────┘
                    ↓
    ┌─────────────────────────────────┐
    │  Custom Values File             │  -f custom-values.yaml
    │  -f custom.yaml                 │  (Overrides defaults)
    └─────────────────────────────────┘
                    ↓
    ┌─────────────────────────────────┐
    │  Default values.yaml            │  Built-in defaults
    │  (in chart)                     │  (Lowest priority)
    └─────────────────────────────────┘
    Lowest Priority ⬇️


Example:
┌─────────────────────────────────────────────────────────────┐
│ Chart's values.yaml:     replicas: 2                        │
│ Custom values.yaml:      replicas: 5                        │
│ Command line:            --set replicas=10                  │
│                                                              │
│ Result: replicas = 10  (command line wins!)                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 Our 2-Tier App Helm Chart

```
┌────────────────────────────────────────────────────────────┐
│              2-Tier Application Architecture                │
└────────────────────────────────────────────────────────────┘

                    helm install my-app ./2-tier-helm-chart
                                    │
                                    ▼
        ┌───────────────────────────────────────────────┐
        │           Kubernetes Cluster                   │
        │                                                │
        │  ┌─────────────────┐    ┌──────────────────┐ │
        │  │  MySQL Pod      │◄───│  MySQL Service   │ │
        │  │                 │    │  (ClusterIP)     │ │
        │  │  - mysql:8.0    │    │  Port: 3306      │ │
        │  │  - Port: 3306   │    └──────────────────┘ │
        │  │                 │                          │
        │  │  Environment:   │                          │
        │  │  - DB creds ────┼─ From Secret            │
        │  │                 │                          │
        │  │  Storage:       │                          │
        │  │  - 1Gi PVC ─────┼─ From PVC               │
        │  └─────────────────┘                          │
        │           ▲                                   │
        │           │ DNS: mysql-service                │
        │           │                                   │
        │  ┌────────┴────────┐    ┌──────────────────┐ │
        │  │  Webapp Pods    │    │ Webapp Service   │ │
        │  │  (2 replicas)   │◄───│  (NodePort)      │ │
        │  │                 │    │  Port: 30080     │ │
        │  │  - webapp:latest│    └──────────────────┘ │
        │  │  - Port: 5000   │             │           │
        │  │                 │             │           │
        │  │  Environment:   │             │           │
        │  │  - DB_HOST ─────┼─ From ConfigMap        │
        │  │  - DB_USER ─────┼─ From Secret           │
        │  └─────────────────┘             │           │
        │                                   │           │
        └───────────────────────────────────┼───────────┘
                                            │
                                            ▼
                                ┌────────────────────┐
                                │   User Browser     │
                                │ localhost:30080    │
                                └────────────────────┘

Resources Created by Helm:
┌────────────────────────────────────┐
│ ✅ Secret (mysql-secret)           │  Database credentials
│ ✅ PVC (mysql-pvc)                 │  Persistent storage
│ ✅ Deployment (mysql)              │  MySQL pod
│ ✅ Service (mysql-service)         │  Internal access
│ ✅ ConfigMap (webapp-config)       │  App configuration
│ ✅ Deployment (webapp)             │  Webapp pods
│ ✅ Service (webapp-service)        │  External access
└────────────────────────────────────┘
```

---

## 🚀 Deployment Workflow

```
┌────────────────────────────────────────────────────────────┐
│              Complete Deployment Workflow                   │
└────────────────────────────────────────────────────────────┘

1️⃣  Prepare
    ┌─────────────────┐
    │ Build Docker    │  docker build -t webapp:latest .
    │ Image           │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Load into Kind  │  kind load docker-image webapp:latest
    └────────┬────────┘
             │
             ▼

2️⃣  Validate
    ┌─────────────────┐
    │ Lint Chart      │  helm lint ./2-tier-helm-chart
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Dry Run         │  helm install test ./chart --dry-run
    └────────┬────────┘
             │
             ▼

3️⃣  Install
    ┌─────────────────┐
    │ Install Chart   │  helm install my-app ./2-tier-helm-chart
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Release Created │  Revision 1 (DEPLOYED)
    │                 │  All K8s resources created
    └────────┬────────┘
             │
             ▼

4️⃣  Verify
    ┌─────────────────┐
    │ Check Status    │  helm status my-app
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Check Pods      │  kubectl get pods
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Access App      │  http://localhost:30080
    └─────────────────┘


5️⃣  Manage
    ┌─────────────────┐
    │ Upgrade?        │  helm upgrade my-app ./chart --set replicas=5
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Rollback?       │  helm rollback my-app
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Uninstall?      │  helm uninstall my-app
    └─────────────────┘
```

---

## 📊 Helm Commands Map

```
┌────────────────────────────────────────────────────────────┐
│                  Helm Command Categories                    │
└────────────────────────────────────────────────────────────┘

📦 CHART OPERATIONS
├─ helm create <name>          Create new chart
├─ helm lint <chart>           Validate chart
├─ helm template <name> <chart> Render templates locally
├─ helm package <chart>        Create .tgz package
└─ helm show [chart|values|readme] <chart>  View chart info

🚀 RELEASE OPERATIONS
├─ helm install <name> <chart> Install a chart
├─ helm upgrade <name> <chart> Upgrade a release
├─ helm rollback <name>        Rollback to previous version
├─ helm uninstall <name>       Remove a release
└─ helm upgrade --install      Install or upgrade (useful!)

📋 INFORMATION
├─ helm list                   List all releases
├─ helm status <name>          Show release status
├─ helm history <name>         Show release history
├─ helm get [all|values|manifest|notes] <name>  Get release info
└─ helm get values <name>      Show values used in release

🌐 REPOSITORY OPERATIONS
├─ helm repo add <name> <url>  Add a repository
├─ helm repo update            Update all repos
├─ helm repo list              List repositories
├─ helm repo remove <name>     Remove a repository
└─ helm search repo <keyword>  Search in repositories

🔍 TESTING & DEBUGGING
├─ helm install --dry-run      Preview without installing
├─ helm template               Generate YAML without installing
├─ helm lint                   Check for issues
└─ helm get manifest <name>    View deployed YAML
```

---

## 🎓 Learning Path Visualization

```
┌────────────────────────────────────────────────────────────┐
│               Your Helm Learning Journey                    │
└────────────────────────────────────────────────────────────┘

Week 1: Foundations
    ┌─────────────────┐
    │ Understand      │ ← Read HELM_TUTORIAL.md
    │ Concepts        │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Install Helm    │ ← Get Helm running
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Add Repos &     │ ← Try public charts
    │ Install Charts  │
    └─────────────────┘

Week 2: Hands-On
    ┌─────────────────┐
    │ Deploy 2-Tier   │ ← Use this repo
    │ App with Helm   │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Customize       │ ← Create custom values
    │ Values          │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Upgrade &       │ ← Practice lifecycle
    │ Rollback        │
    └─────────────────┘

Week 3: Advanced
    ┌─────────────────┐
    │ Create Your     │ ← helm create myapp
    │ Own Chart       │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Package &       │ ← Share with team
    │ Share Charts    │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Use in CI/CD    │ ← Automate deployments
    └─────────────────┘

    🎉 You're now a Helm expert!
```

---

## 🎯 Quick Decision Trees

### Should I use Helm?

```
Do you have multiple K8s YAML files?
    │
    ├─ No ─► Single YAML → kubectl apply -f file.yaml ✅
    │
    └─ Yes ─► Multiple environments (dev/prod)?
            │
            ├─ No ─► Kustomize might be simpler
            │
            └─ Yes ─► Need to share with others?
                    │
                    ├─ No ─► Kustomize might work
                    │
                    └─ Yes ─► Use Helm! 🎉
```

### When to upgrade vs rollback?

```
New version available?
    │
    ├─ Test passed ─► helm upgrade ✅
    │
    └─ Test failed ─► Issue in new version?
                    │
                    ├─ Yes ─► helm rollback ⏪
                    │
                    └─ No ─► Fix config & helm upgrade again
```

---

## 📝 Template Syntax Quick Reference

```yaml
# Values
{{ .Values.key }}                # Simple value
{{ .Values.nested.key }}         # Nested value

# Default values
{{ .Values.key | default "value" }}

# Conditionals
{{- if .Values.enabled }}
  enabled: true
{{- else }}
  enabled: false
{{- end }}

# Loops
{{- range .Values.items }}
- name: {{ . }}
{{- end }}

# Include templates
{{ include "chart.name" . }}

# Chart info
{{ .Chart.Name }}                # Chart name
{{ .Chart.Version }}             # Chart version
{{ .Release.Name }}              # Release name
{{ .Release.Namespace }}         # Namespace

# String functions
{{ .Values.name | quote }}       # Add quotes
{{ .Values.name | upper }}       # Uppercase
{{ .Values.name | lower }}       # Lowercase
{{ .Values.name | trunc 63 }}    # Truncate

# Indentation
{{ toYaml .Values.resources | indent 2 }}
{{ include "template" . | nindent 4 }}
```

---

## 🎉 Success Checklist

```
After completing this guide, you should be able to:

✅ Explain what Helm is and why it's useful
✅ Understand Helm terminology (Chart, Release, Values, etc.)
✅ Install Helm on your system
✅ Add and manage Helm repositories
✅ Install charts from repositories
✅ Create a basic Helm chart
✅ Customize charts with values files
✅ Use --set to override values
✅ Deploy applications using Helm
✅ Upgrade running releases
✅ Rollback to previous versions
✅ Package and share charts
✅ Debug Helm issues
✅ Use Helm in different environments
✅ Read and understand Helm templates

🎊 Congratulations! You're now Helm-proficient!
```

---

**Remember**: These diagrams are here to help you visualize concepts. Refer back to them whenever you need clarity!

Happy Helming! 🚀

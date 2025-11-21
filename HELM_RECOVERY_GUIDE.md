# 🔄 Helm Recovery Guide: Getting Back Deleted Objects

## 📋 Understanding Helm Deletion

When you run `helm uninstall`, Helm removes the release and all its Kubernetes resources. However, there are ways to recover!

---

## 🆘 Recovery Scenarios

### Scenario 1: Uninstalled with `--keep-history` ✅ RECOVERABLE

If you uninstalled with the `--keep-history` flag, the release metadata is still in the cluster!

#### Check if history exists:
```bash
# List all releases including uninstalled ones
helm list --all

# Or check specific namespace
helm list --all -n <namespace>

# Check history of the release
helm history <release-name>
```

#### Recover the release:
```bash
# Method 1: Rollback to last working revision
helm rollback <release-name>

# Method 2: Rollback to specific revision
helm rollback <release-name> <revision-number>

# Example:
helm rollback my-app 3
```

**This will recreate all Kubernetes resources!** ✅

---

### Scenario 2: Uninstalled WITHOUT `--keep-history` ❌ HARDER TO RECOVER

If you ran `helm uninstall <release>` without `--keep-history`, the release metadata is gone.

#### Option A: Reinstall with Same Configuration
```bash
# If you have the chart and values file
helm install <release-name> <chart-path> -f <values-file>

# Example:
helm install my-app ./2-tier-helm-chart -f my-values.yaml
```

#### Option B: Recover from Backup
```bash
# If you backed up the manifests before deletion
kubectl apply -f backup-manifests.yaml
```

#### Option C: Check Kubernetes Events (Recent deletions only)
```bash
# See recent events (may show what was deleted)
kubectl get events --sort-by='.lastTimestamp' | grep -i delete

# Check in specific namespace
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

---

### Scenario 3: Deleted Individual Kubernetes Resources (Not Helm Uninstall)

If you deleted K8s resources directly (not via Helm):

```bash
# Helm will show the release as partially deployed
helm list

# Check what's missing
helm status <release-name>

# Repair by upgrading (will recreate missing resources)
helm upgrade <release-name> <chart-path>
```

---

## 🛡️ Prevention: Best Practices

### 1. Always Keep History When Uninstalling
```bash
# Instead of:
helm uninstall my-app

# Use:
helm uninstall my-app --keep-history
```

### 2. Backup Before Uninstalling
```bash
# Save current manifests
helm get manifest <release-name> > backup-$(date +%Y%m%d-%H%M%S).yaml

# Save values used
helm get values <release-name> > values-backup.yaml

# Then uninstall safely
helm uninstall <release-name> --keep-history
```

### 3. Export Configuration Regularly
```bash
# Export all releases in a namespace
for release in $(helm list -q); do
    echo "Backing up $release..."
    helm get manifest $release > "backup-$release.yaml"
    helm get values $release > "values-$release.yaml"
done
```

### 4. Use Version Control
```bash
# Keep your charts and values in Git
git add .
git commit -m "Current configuration for my-app"
git push
```

---

## 🔍 Step-by-Step Recovery Process

### Step 1: Check if History Exists
```bash
# List all releases (including deleted)
helm list --all --all-namespaces

# Check the specific release
helm history <release-name>
```

**Output Example:**
```
REVISION  UPDATED                   STATUS        CHART           DESCRIPTION
1         Mon Nov 20 10:00:00 2025  superseded    myapp-0.1.0    Install complete
2         Mon Nov 20 11:00:00 2025  uninstalled   myapp-0.1.0    Uninstallation complete
```

### Step 2: Identify the Last Good Revision
```bash
# Look for the last "deployed" or "superseded" revision
helm history <release-name>
```

### Step 3: Rollback to That Revision
```bash
# Rollback (will recreate all resources)
helm rollback <release-name> <revision-number>

# Example: Rollback to revision 1
helm rollback my-app 1
```

### Step 4: Verify Recovery
```bash
# Check release status
helm status <release-name>

# Check pods
kubectl get pods

# Check all resources
kubectl get all -l "app.kubernetes.io/instance=<release-name>"
```

---

## 💻 Practical Examples

### Example 1: Recover Recently Uninstalled Release (with history)

```bash
# 1. Check if release exists in history
helm list --all
# Output: my-app  default  3  2025-11-21  uninstalled  2-tier-app-0.1.0

# 2. Check history
helm history my-app
# Output:
# REVISION  STATUS        CHART              DESCRIPTION
# 1         superseded    2-tier-app-0.1.0  Install complete
# 2         superseded    2-tier-app-0.1.0  Upgrade complete
# 3         uninstalled   2-tier-app-0.1.0  Uninstall complete

# 3. Rollback to revision 2 (last working version)
helm rollback my-app 2

# 4. Verify
helm status my-app
kubectl get pods
```

### Example 2: Recover Without History (Reinstall)

```bash
# 1. If you have the original chart and values
helm install my-app ./2-tier-helm-chart -f my-values.yaml

# 2. If you need the default values
helm install my-app ./2-tier-helm-chart

# 3. Verify
helm list
kubectl get pods
```

### Example 3: Partial Resource Deletion (Direct kubectl delete)

```bash
# Someone accidentally ran: kubectl delete deployment my-app-webapp

# 1. Check Helm status
helm status my-app
# Will show some resources missing

# 2. Repair by upgrading (recreates missing resources)
helm upgrade my-app ./2-tier-helm-chart

# 3. Or force reinstall
helm upgrade --install my-app ./2-tier-helm-chart --force
```

---

## 🚨 Emergency Recovery Commands

### Quick Recovery Checklist
```bash
# 1. Check what's available
helm list --all --all-namespaces

# 2. Check history
helm history <release-name>

# 3. Rollback
helm rollback <release-name>

# 4. If rollback fails, try specific revision
helm rollback <release-name> 1

# 5. If no history, reinstall
helm install <release-name> <chart> -f values.yaml

# 6. Verify
helm status <release-name>
kubectl get all
```

---

## 📊 Understanding Helm Revisions

Every time you interact with a release, Helm creates a new revision:

```
Revision 1: helm install my-app ./chart
Revision 2: helm upgrade my-app ./chart --set replicas=5
Revision 3: helm rollback my-app (back to revision 1)
Revision 4: helm uninstall my-app --keep-history
```

**You can rollback to ANY revision except the uninstalled one!**

---

## 🔧 Advanced Recovery Techniques

### Recover from Kubernetes Backup (if available)

```bash
# If you have etcd backups or Velero backups
# Restore the namespace containing the release
velero restore create --from-backup <backup-name>
```

### Recreate from Helm Cache (if available)

```bash
# Helm stores release info in secrets
kubectl get secrets -n <namespace> | grep "sh.helm.release"

# Get the secret
kubectl get secret sh.helm.release.v1.<release-name>.v<revision> -o yaml

# This is complex - better to use helm rollback if possible
```

### Force Reinstall Over Existing Resources

```bash
# If some resources still exist and you want to force reinstall
helm upgrade --install <release-name> <chart> --force

# Or completely clean and reinstall
kubectl delete all -l "app.kubernetes.io/instance=<release-name>"
helm install <release-name> <chart>
```

---

## 📝 Real-World Scenarios

### Scenario A: "I accidentally ran `helm uninstall my-app`"

**Solution:**
```bash
# 1. Try rollback first (might work if history exists)
helm rollback my-app

# 2. If that fails, check what you can see
helm list --all

# 3. If no history, reinstall
helm install my-app ./2-tier-helm-chart -f my-values.yaml
```

### Scenario B: "I deleted a deployment with kubectl by mistake"

**Solution:**
```bash
# Helm will detect missing resources on next upgrade
helm upgrade my-app ./2-tier-helm-chart

# This recreates the deleted deployment
```

### Scenario C: "I need to recover to a specific configuration from yesterday"

**Solution:**
```bash
# 1. Check history
helm history my-app

# 2. Identify the revision from yesterday
# 3. Rollback to that revision
helm rollback my-app <revision-number>
```

---

## ✅ Testing Recovery (Practice)

Try this safe exercise:

```bash
# 1. Install something
helm install test-app ./2-tier-helm-chart

# 2. Make a change
helm upgrade test-app ./2-tier-helm-chart --set webapp.replicas=5

# 3. Check history
helm history test-app

# 4. Uninstall WITH history
helm uninstall test-app --keep-history

# 5. Check it's gone
helm list
kubectl get pods

# 6. RECOVER IT!
helm rollback test-app

# 7. Verify it's back
helm list
kubectl get pods

# 8. Clean up
helm uninstall test-app
```

---

## 🎓 Key Takeaways

✅ **Always use `--keep-history`** when uninstalling  
✅ **Backup manifests and values** before major changes  
✅ **Use version control** for charts and values  
✅ **Test recovery procedures** in non-production first  
✅ **Document your configurations** so you can recreate them  
✅ **Use `helm rollback`** - it's your best friend!  

---

## 🆘 Quick Reference Card

| Situation | Command |
|-----------|---------|
| Check if recovery possible | `helm list --all` |
| View release history | `helm history <release>` |
| Rollback to previous | `helm rollback <release>` |
| Rollback to specific revision | `helm rollback <release> <rev>` |
| Reinstall from scratch | `helm install <release> <chart>` |
| Repair missing resources | `helm upgrade <release> <chart>` |
| Force recreation | `helm upgrade --install <release> <chart> --force` |

---

## 📞 When All Else Fails

If you can't recover:

1. **Check Git** - Your charts and values should be version controlled
2. **Check Backups** - Kubernetes cluster backups, Velero, etc.
3. **Recreate** - Use the chart and redeploy with known configuration
4. **Learn** - Set up proper backup procedures going forward

---

## 🎯 For Our 2-Tier App

### Quick Recovery:
```bash
# If deleted by mistake
helm rollback my-2tier-app

# If that doesn't work, reinstall
cd /home/anataraj/Projects/cka/2-tier-app
helm install my-2tier-app ./2-tier-helm-chart

# Or use the quick-start script
./helm-quickstart.sh --full
```

---

**Remember: Prevention is better than recovery! Always use `--keep-history` and backup your configurations!**

---

*Last Updated: November 21, 2025*  
*Part of the Helm Zero-to-Hero Guide*

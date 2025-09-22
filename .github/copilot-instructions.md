# Infrastructure Repository - GitHub Copilot Instructions

# Infrastructure Repository – Copilot Instructions

This monorepo manages home lab infrastructure-as-code. Key components:

## Structure

- **/terraform/**: Infrastructure provisioning (AWS, backend state)
- **/kubernetes/**: Container orchestration (ArgoCD, bootstrap, apps, infra)

## Coding Guidelines

### Terraform

- Use hyphenated resource names (e.g., `aws-instance-name`).
- Always add `tags` with `Project = "infrastructure/component"`.
- Store sensitive values in `terraform.tfvars` (gitignored).

### Kubernetes

- Use namespaces for organization.
- Use hostPath volumes for single-node clusters (NFS-backed).
- Do NOT specify resource limits/requests unless absolutely necessary and explained in a comment.
- Deploy via GitOps with ArgoCD.
- For large ConfigMaps, use Kustomize `configMapGenerator` with separate files (not inline YAML) for readability and editing.

### Storage & NFS Permissions

All apps using persistent storage must run with these securityContext values for NFS access:

```yaml
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 101000
        runAsGroup: 110000
        fsGroup: 110000
```

Mount points:

- `/home/nas/shared/pvcs/` – app data/configs/dbs
- `/home/nas/media/` – media/content

**Use these IDs (101000/110000) for write access everywhere.**

### Secrets Management

Sensitive data is managed by the custom [`k8s-secrets-sync`](https://github.com/jackweinbender/k8s-secrets-sync) operator, syncing from 1Password.

**Required annotations:**

```yaml
metadata:
  annotations:
    "k8s-secrets-sync.weinbender.io/provider-name": "op"
    "k8s-secrets-sync.weinbender.io/secret-key": "password"
    "k8s-secrets-sync.weinbender.io/provider-ref": "op://vault/item/field"
```

**Best practices:**

- One secret per Kubernetes Secret (operator limitation)
- Only truly sensitive data as secrets
- Use ConfigMaps for non-sensitive config (prefer configMapGenerator for large configs)
- Name secrets `{service}-{purpose}` (e.g., `postgresql-password`)
- 1Password refs: `op://vault/item/field`

**Example:**

```yaml
# Secret (managed by 1Password)
apiVersion: v1
kind: Secret
metadata:
  name: app-database-password
  annotations:
    "k8s-secrets-sync.weinbender.io/provider-name": "op"
    "k8s-secrets-sync.weinbender.io/secret-key": "password"
    "k8s-secrets-sync.weinbender.io/provider-ref": "op://microk8s/app-db/password"
---
# ConfigMap (non-sensitive)
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-database-config
data:
  DB_HOST: "database.app.svc.cluster.local"
  DB_NAME: "app_production"
  DB_USER: "app_user"
```

### ArgoCD Projects

Use these ArgoCD projects:

- `default`: Most apps (recommended)
- `system`: Core infra (ArgoCD, cert-manager, monitoring)
- `app`: App-specific deployments

Default to `project: default` unless infra/monitoring.

### ArgoCD Application Sync Policy

All ArgoCD apps must use this sync policy unless otherwise noted in a comment in the manifest:

```yaml
syncPolicy:
  syncOptions:
    - CreateNamespace=true
    - Validate=true
    - Prune=true
  automated:
    prune: true
    selfHeal: true
```

This ensures reliable GitOps and avoids conflicts from complex options. If a different sync policy is required for a specific app, add a clear comment in the manifest explaining the reason for the deviation.

### Resource-Specific Sync Policies

Override app-level sync policy with annotations as needed:

**Force secret recreation (for k8s-secrets-sync):**

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-options: "Force=true,Replace=true"
    "k8s-secrets-sync.weinbender.io/provider-name-name": "op"
    "k8s-secrets-sync.weinbender.io/provider-name-ref": "op://vault/item/field"
    "k8s-secrets-sync.weinbender.io/secret-key": "password"
```

**Other common options:**

- `Replace=true`: Delete/recreate resource (needed for secrets)
- `Force=true`: Force apply (with Replace)
- `Validate=false`: Skip validation
- `Prune=false`: Prevent auto-deletion
- `SkipDryRunOnMissingResource=true`: For resources that don't support dry-run

**Sync hooks:**

```yaml
metadata:
  annotations:
    argocd.argoproj.io/hook: "PreSync"
    argocd.argoproj.io/hook-delete-policy: "BeforeHookCreation"
```

**Best practice:** Always use `Force=true,Replace=true` for k8s-secrets-sync secrets. Keep app-level sync policy simple.

## Security Considerations

- Secrets: k8s-secrets-sync + 1Password
- Legacy: Ansible Vault
- SSH: Managed via GitHub
- Network: Tailscale mesh VPN
- SSL: cert-manager/Let's Encrypt
- Storage: ZFS + NFS, correct permissions

## Environment Context

- OS: Ubuntu/Debian
- Container runtime: Docker/containerd
- Kubernetes: MicroK8s (single-node)
- DNS: Internal `*.k8s.weinbender.io`
- Storage: ZFS → NFS → Ubuntu VM → hostPath
- Secrets: k8s-secrets-sync + 1Password
- Monitoring: systemd/journald

**Prioritize simplicity, maintainability, and cost-effectiveness for home lab use.**

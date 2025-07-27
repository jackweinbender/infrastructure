# Infrastructure Repository - GitHub Copilot Instructions

This is a monorepo containing infrastructure-as-code for a home lab environment. The repository is organized into three main components:

## Repository Structure

### `/terraform/` - Infrastructure Provisioning

- **AWS**: EC2 instances, VPC, S3 buckets, and other AWS resources
- **Proxmox**: Virtual machine management for on-premises infrastructure
- **Tailscale**: VPN mesh network configuration
- **Management**: Terraform backend state management

### `/ansible/` - Configuration Management

- **Roles**: `core`, `ingress`, `onepassword`, `tailscale`
- **Playbooks**: Bootstrap scripts and inventory management

### `/kubernetes/` - Container Orchestration

- **ArgoCD**: GitOps deployment and application management
- **Bootstrap**: Initial cluster setup scripts
- **Applications**: Jellyfin media server and other services
- **Infrastructure**: MetalLB, cert-manager, Envoy Gateway

## Coding Guidelines

### Terraform

- Use consistent naming conventions with hyphens (e.g., `aws-instance-name`)
- Always include `tags` with `Project = "infrastructure/component"`
- Keep sensitive values in `terraform.tfvars` (gitignored)

### Ansible

- Prefix role variables with role name (e.g., `ingress_enabled_sites`)
- Use `ansible.builtin` modules when available
- Store sensitive data in Ansible Vault

### Kubernetes

- Use namespaces to organize resources
- Use hostPath volumes for single-node clusters with NFS-backed storage
- Configure resource limits and requests
- Use GitOps patterns with ArgoCD for deployments

#### Storage & NFS Permissions

The storage architecture uses ZFS → NFS → Ubuntu VM → hostPath volumes. All applications using persistent storage must run with specific user/group IDs to access NFS-mounted directories:

**Required Security Context for NFS Storage:**

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

**Storage Mount Points:**

- **Shared storage**: `/home/nas/shared/pvcs/` (application data, configs, databases)
- **Media storage**: `/home/nas/media/` (media files, large datasets, content)

**Important**: These user/group IDs (101000/110000) are required for write access to both NFS mount points and must be used consistently across all deployments.

#### Secrets Management

Sensitive data is managed using the custom `k8s-secrets-sync` operator (https://github.com/jackweinbender/k8s-secrets-sync) that syncs secrets from 1Password:

**Required Annotations for 1Password Integration:**

```yaml
metadata:
  annotations:
    "k8s-secrets-sync.weinbender.io/provider": "op"
    "k8s-secrets-sync.weinbender.io/secret-key": "password" # Key name in secret data
    "k8s-secrets-sync.weinbender.io/ref": "op://vault/item/field"
```

**Best Practices:**

- **One secret per Kubernetes Secret**: The operator limitation requires one sensitive value per secret
- **Minimize secrets**: Only truly sensitive data (passwords, tokens) should use secrets
- **Use ConfigMaps**: Non-sensitive configuration should be stored in ConfigMaps
- **Naming convention**: Use descriptive names like `{service}-{purpose}` (e.g., `postgresql-password`)
- **1Password references**: Use format `op://vault-name/item-name/field-name`

**Example Secret Structure:**

```yaml
# Only the password - managed via 1Password
apiVersion: v1
kind: Secret
metadata:
  name: app-database-password
  annotations:
    "k8s-secrets-sync.weinbender.io/provider": "op"
    "k8s-secrets-sync.weinbender.io/secret-key": "password"
    "k8s-secrets-sync.weinbender.io/ref": "op://microk8s/app-db/password"
---
# Non-sensitive config - regular ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-database-config
data:
  DB_HOST: "database.app.svc.cluster.local"
  DB_NAME: "app_production"
  DB_USER: "app_user"
```

#### ArgoCD Application Sync Policy

All ArgoCD applications must use the standardized sync policy for consistent behavior and reliability. Use this exact sync policy configuration for all applications:

**Standard Sync Policy:**

```yaml
syncPolicy:
  syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true
    - Validate=true
    - PruneLast=true
  automated:
    prune: true
    selfHeal: true
```

**Sync Options Explanation:**

- **CreateNamespace=true**: Automatically creates target namespaces if they don't exist
- **ServerSideApply=true**: Uses server-side apply for better field ownership and conflict resolution with operators
- **Validate=true**: Validates resources before applying to catch configuration errors early
- **PruneLast=true**: Ensures resources are pruned after new ones are applied, preventing conflicts
- **automated.prune=true**: Automatically removes resources no longer defined in Git
- **automated.selfHeal=true**: Automatically corrects any configuration drift

**Important**: Do not use `ApplyOutOfSyncOnly=true` as it can cause issues with interdependent resources and operators. ServerSideApply is preferred for this infrastructure setup.

#### Resource-Specific Sync Policies

For resources that need special handling, use annotations to override the application-level sync policy:

**Force Secret Recreation:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sensitive-secret
  annotations:
    argocd.argoproj.io/sync-options: "Replace=true"
    "k8s-secrets-sync.weinbender.io/provider": "op"
    "k8s-secrets-sync.weinbender.io/secret-key": "password"
    "k8s-secrets-sync.weinbender.io/ref": "op://vault/item/field"
```

**Common Resource-Level Sync Options:**

- **`Replace=true`**: Delete and recreate the resource (useful for secrets that need fresh state)
- **`Force=true`**: Force apply even with conflicts (use sparingly)
- **`Validate=false`**: Skip validation for problematic resources
- **`Prune=false`**: Prevent auto-deletion when removed from Git
- **`SkipDryRunOnMissingResource=true`**: Skip dry-run validation for resources that don't support it

**Sync Hooks for Complex Workflows:**

```yaml
metadata:
  annotations:
    argocd.argoproj.io/hook: "PreSync"
    argocd.argoproj.io/hook-delete-policy: "BeforeHookCreation"
```

**Best Practices:**

- Use `Replace=true` for secrets that need clean state
- Use sync hooks for resources with complex dependencies
- Avoid `Force=true` unless absolutely necessary
- Test resource-specific policies in non-production first

## Security Considerations

Sensitive data is managed via custom `k8s-secrets-sync` operator + 1Password:

- **Secrets Management**: Custom k8s-secrets-sync operator with 1Password
- **Ansible Vault**: Legacy secrets and configuration management
- **SSH Keys**: Centrally managed through GitHub
- **Network Access**: Controlled via Tailscale mesh VPN
- **SSL Certificates**: Managed via Let's Encrypt/cert-manager
- **Storage Security**: ZFS + NFS with proper filesystem permissions

## Environment Context

- **Target OS**: Debian-based systems (Ubuntu/Debian)
- **Container Runtime**: Docker/containerd
- **Kubernetes Distribution**: MicroK8s (single-node)
- **DNS**: Internal `.weinbender.io` domain
- **Storage**: ZFS pool → NFS → Ubuntu VM → hostPath volumes
- **Secrets**: Custom k8s-secrets-sync operator with 1Password
- **Monitoring**: Basic logging via systemd/journald

When suggesting changes, consider the home lab context - prioritize simplicity, maintainability, and cost-effectiveness over enterprise complexity.

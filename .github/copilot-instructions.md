# Infrastructure Repository - GitHub Copilot Instructions

This is a monorepo containing infrastructure-as-code for a home lab environment. The repository is organized into three main components:

## Repository Structure

### `/terraform/` - Infrastructure Provisioning

- **AWS**: EC2 instances, VPC, S3 buckets, and other AWS resources
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
- **ConfigMap Best Practice**: For large configuration files, create separate files and use Kustomize `configMapGenerator` instead of inline YAML. This improves readability, enables syntax highlighting, and makes editing easier (e.g., `alloy.river` file with configMapGenerator vs inline River config).

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
- **Use ConfigMaps**: Non-sensitive configuration should be stored in ConfigMaps, preferably using configMapGenerator for large configs.
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

#### ArgoCD Projects

The ArgoCD instance uses three projects for organizing applications:

- **`default`**: Most applications should use this project (recommended for new deployments)
- **`system`**: Core infrastructure components (ArgoCD itself, cert-manager, monitoring tools like Grafana Alloy, etc.)
- **`app`**: Application-specific deployments

When creating new ArgoCD applications, use `project: default` unless there's a specific reason to use a different project. Use `project: system` for infrastructure components that monitor or manage the cluster itself.

#### ArgoCD Application Sync Policy

All ArgoCD applications must use the standardized sync policy for consistent behavior and reliability. Use this exact sync policy configuration for all applications:

**Standard Sync Policy:**

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

**Sync Options Explanation:**

- **CreateNamespace=true**: Automatically creates target namespaces if they don't exist
- **Validate=true**: Validates resources before applying to catch configuration errors early
- **Prune=true**: Automatically removes resources no longer defined in Git at the application level
- **automated.prune=true**: Enables automatic pruning of resources
- **automated.selfHeal=true**: Automatically corrects any configuration drift

**Important**: This simplified sync policy provides reliable GitOps behavior while avoiding potential conflicts that can arise from more complex sync options like `ServerSideApply` or `PruneLast`.

#### Resource-Specific Sync Policies

For resources that need special handling, use annotations to override the application-level sync policy:

**Force Secret Recreation (Required for k8s-secrets-sync managed secrets):**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sensitive-secret
  annotations:
    argocd.argoproj.io/sync-options: "Force=true,Replace=true"
    "k8s-secrets-sync.weinbender.io/provider": "op"
    "k8s-secrets-sync.weinbender.io/secret-key": "password"
    "k8s-secrets-sync.weinbender.io/ref": "op://vault/item/field"
```

**Common Resource-Level Sync Options:**

- **`Replace=true`**: Delete and recreate the resource (required for secrets managed by k8s-secrets-sync)
- **`Force=true`**: Force apply even with conflicts (required with Replace for secrets)
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

- Always use `Force=true,Replace=true` for secrets managed by k8s-secrets-sync operator
- Keep the application-level sync policy simple and consistent

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
- **DNS**: Internal `*.k8s.weinbender.io` domain for all services exposed via the cluster gateway
- **Storage**: ZFS pool → NFS → Ubuntu VM → hostPath volumes
- **Secrets**: Custom k8s-secrets-sync operator with 1Password
- **Monitoring**: Basic logging via systemd/journald

When suggesting changes, consider the home lab context - prioritize simplicity, maintainability, and cost-effectiveness over enterprise complexity.

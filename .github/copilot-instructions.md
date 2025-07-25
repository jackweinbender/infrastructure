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

# Infrastructure Repository - GitHub Copilot Instructions

This is a monorepo containing infrastructure-as-code for a home lab environment. The repository is organized into three main components:

## Repository Structure

### `/terraform/` - Infrastructure Provisioning

- **AWS**: EC2 instances, VPC, S3 buckets, and other AWS resources
- **Proxmox**: Virtual machine management for on-premises infrastructure
- **Tailscale**: VPN mesh network configuration
- **Management**: Terraform backend state management

Each directory contains:

- `backend.tf` - Terraform state backend configuration
- `providers.tf` - Provider versions and configuration
- `*.tf` - Resource definitions
- `terraform.tfvars.tmpl` - Template for variables (secrets excluded)

### `/ansible/` - Configuration Management

- **Roles**:
  - `core`: Base system configuration, users, packages
  - `ingress`: Nginx reverse proxy with SSL termination
  - `onepassword`: 1Password CLI setup
  - `tailscale`: VPN client configuration
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
- Use data sources for dynamic lookups when possible
- Keep sensitive values in `terraform.tfvars` (gitignored)
- Use modules for reusable components

### Ansible

- Prefix role variables with role name (e.g., `ingress_enabled_sites`)
- Use `ansible.builtin` modules when available
- Implement idempotency checks
- Use handlers for service restarts
- Store sensitive data in Ansible Vault

### Kubernetes

- Use namespaces to organize resources
- Implement proper RBAC with least privilege
- Use PersistentVolumeClaims for stateful applications
- Configure resource limits and requests
- Use GitOps patterns with ArgoCD for deployments

## Security Considerations

- Secrets are managed via 1Password and Ansible Vault
- SSH keys are centrally managed through GitHub
- Network access is controlled via Tailscale mesh VPN
- SSL certificates are managed via Let's Encrypt/cert-manager

## Common Tasks

### Adding a new service

1. Create Kubernetes manifests in `/kubernetes/{service-name}/`
2. Add ArgoCD application in `/kubernetes/argo-applications/`
3. Update Nginx ingress configuration if external access needed
4. Document any required secrets or configuration

### Adding infrastructure

1. Define resources in appropriate Terraform directory
2. Update Ansible roles for configuration management
3. Test in development environment first
4. Apply via Terraform with proper state backend

### Network Changes

1. Update Tailscale configuration for new devices/routes
2. Modify Nginx reverse proxy rules if needed
3. Update firewall rules and security groups
4. Test connectivity end-to-end

## Environment Context

- **Target OS**: Debian-based systems (Ubuntu/Debian)
- **Container Runtime**: Docker/containerd
- **Kubernetes Distribution**: MicroK8s
- **DNS**: Internal `.weinbender.io` domain
- **Storage**: NFS shares for persistent data
- **Monitoring**: Basic logging via systemd/journald

When suggesting changes, consider the home lab context - prioritize simplicity, maintainability, and cost-effectiveness over enterprise complexity.

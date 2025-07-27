# Twenty CRM

This directory contains Kubernetes manifests for deploying Twenty CRM, an open-source customer relationship management system.

## Components

- **Namespace**: `twenty` - Isolated namespace for the application
- **Deployment**: Runs the Twenty CRM application container
- **Service**: ClusterIP service exposing the application internally
- **HTTPRoute**: Gateway API route for external access via `twenty.k8s.weinbender.io`
- **Secret**: PostgreSQL password managed via k8s-secrets-sync and 1Password

## Configuration

### Database
The application connects to the shared PostgreSQL instance in the `postgresql` namespace. The database connection is configured via environment variables:
- Database URL uses the shared PostgreSQL service
- Credentials are managed via 1Password secret sync

### Storage
- Uses hostPath volume mounted at `/app/.local-storage`
- Backed by NFS storage at `/home/nas/shared/pvcs/twenty`
- Runs with proper security context for NFS access (UID/GID 101000/110000)

### Access
- External access: `https://twenty.k8s.weinbender.io`
- Internal service: `twenty.twenty.svc.cluster.local:80`

## Prerequisites

1. PostgreSQL database instance running
2. 1Password secret `op://microk8s/twenty-postgres/password` configured
3. NFS storage directory `/home/nas/shared/pvcs/twenty` exists with proper permissions

## Deployment

This application is managed by ArgoCD. Changes to this directory will be automatically synchronized to the cluster.

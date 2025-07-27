# Twenty CRM

This directory contains Kubernetes manifests for deploying [Twenty CRM](https://twenty.com), an open-source customer relationship management system built with TypeScript, React, and Node.js.

## Overview

Twenty CRM is deployed as a multi-component application consisting of:

- **Server**: Main application backend (API, GraphQL, authentication)
- **Worker**: Background job processing (emails, data sync, automation)
- **Redis**: Session storage and job queue management
- **Database**: Dedicated PostgreSQL instance with pgvector support

## Important Configuration Notes

### Secret Management

- **Critical**: Do NOT include `data: {}` blocks in secret definitions
- **Reason**: The k8s-secrets-sync operator automatically populates the data field
- **Pattern**: Uses 1Password integration for secure credential management

### Database Configuration

- **Service**: `twentycrm-db.twentycrm.svc:5432` (dedicated instance)
- **Database Name**: `twentycrm`
- **Image**: `twentycrm/twenty-postgres-spilo:latest`
- **Migration Strategy**: Server handles schema initialization, worker skips migrations

### Storage Requirements

All deployments require NFS-compatible security context:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 101000
  runAsGroup: 110000
  fsGroup: 110000
```

## Components

### Core Services

- **Namespace**: `twentycrm` - Isolated namespace for the application
- **Server Deployment**: Main Twenty CRM application server
- **Worker Deployment**: Background job processor for async tasks
- **Redis Deployment**: In-memory data store for caching and job queues
- **Services**: ClusterIP services for internal communication
- **HTTPRoute**: Gateway API route for external access via `twenty.k8s.weinbender.io`
- **Secret**: Database credentials managed via k8s-secrets-sync and 1Password

### Storage Architecture

All components use NFS-backed hostPath volumes with proper security context:

- **Server Data**: `/home/nas/shared/pvcs/twentycrm-server` → `/app/packages/twenty-server/.local-storage`
  - File uploads, user data, application state
- **Docker Data**: `/home/nas/shared/pvcs/twentycrm-docker` → `/app/docker-data`
  - General application data, temporary files, logs, build artifacts
- **Redis Data**: `/home/nas/shared/pvcs/twentycrm-redis` → `/data`
  - Persistent cache and session data

## Configuration

### Database Connection

- **Database**: Uses shared PostgreSQL instance in `postgresql` namespace
- **Connection**: `postgresql.postgresql.svc:5432/twenty`
- **Credentials**: Managed via 1Password secret sync
- **Migrations**: Handled automatically by the server component

### Redis Connection

- **Service**: Local Redis instance within `twentycrm` namespace
- **Connection**: `twentycrm-redis.twentycrm.svc:6379`
- **Usage**: Session storage, job queue, caching

### Environment Variables

Key configuration managed through environment variables:

- `SERVER_URL`: External application URL
- `PG_DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `STORAGE_TYPE`: Set to "local" for file system storage
- `APP_SECRET`: Application secret key from 1Password

### Security Context

All pods run with NFS-compatible security context:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 101000
  runAsGroup: 110000
  fsGroup: 110000
```

## External Access

- **Production URL**: `https://twenty.k8s.weinbender.io`
- **Internal Services**:
  - Server: `twentycrm-server.twentycrm.svc.cluster.local:3000`
  - Redis: `twentycrm-redis.twentycrm.svc.cluster.local:6379`

## Prerequisites

1. **Database Setup**:

   - PostgreSQL instance running in `postgresql` namespace
   - Database `twenty` created and accessible
   - 1Password secret `op://microk8s/postgresql-db/password` configured

2. **Storage**:

   - NFS storage directories with proper permissions:
     - `/home/nas/shared/pvcs/twentycrm-server`
     - `/home/nas/shared/pvcs/twentycrm-docker`
     - `/home/nas/shared/pvcs/twentycrm-redis`

3. **Secrets Management**:

   - k8s-secrets-sync operator deployed and configured
   - 1Password vault access for secret synchronization

4. **Networking**:
   - Gateway API configured with Envoy Gateway
   - DNS resolution for `twenty.k8s.weinbender.io`

## Deployment

This application is managed by ArgoCD with automated synchronization. Changes to this directory will be automatically deployed to the cluster.

### Manual Operations

```bash
# Check deployment status
kubectl get pods -n twentycrm

# View logs
kubectl logs -n twentycrm deployment/twentycrm-server
kubectl logs -n twentycrm deployment/twentycrm-worker
kubectl logs -n twentycrm deployment/twentycrm-redis

# Check storage
kubectl exec -n twentycrm deployment/twentycrm-server -- ls -la /app/packages/twenty-server/.local-storage
```

## Twenty CRM Documentation

### Core Documentation

- **Official Documentation**: https://twenty.com/developers
- **Self-Hosting Guide**: https://twenty.com/developers/self-hosting/docker-compose
- **Architecture Overview**: https://twenty.com/developers/frontend/overview

### Technical References

- **Environment Variables**: https://twenty.com/developers/self-hosting/environment-variables
- **Storage Configuration**: https://twenty.com/developers/self-hosting/storage
- **Database Setup**: https://twenty.com/developers/self-hosting/database
- **Redis Configuration**: https://twenty.com/developers/self-hosting/redis

### Kubernetes Specific

- **Official K8s Examples**: https://github.com/twentyhq/twenty/tree/main/packages/twenty-docker/k8s
- **Docker Deployment**: https://github.com/twentyhq/twenty/tree/main/packages/twenty-docker
- **Worker Configuration**: https://twenty.com/developers/backend/worker

### API & Development

- **GraphQL API**: https://twenty.com/developers/backend/graphql
- **REST API**: https://twenty.com/developers/backend/rest-api
- **Authentication**: https://twenty.com/developers/backend/authentication
- **File Upload**: https://twenty.com/developers/backend/file-upload

### Troubleshooting

- **Common Issues**: https://twenty.com/developers/self-hosting/troubleshooting
- **Performance**: https://twenty.com/developers/self-hosting/performance
- **Monitoring**: https://twenty.com/developers/self-hosting/monitoring

## Support

- **GitHub Repository**: https://github.com/twentyhq/twenty
- **Community Discord**: https://discord.gg/cx5n4Jzs57
- **Documentation Issues**: https://github.com/twentyhq/twenty/issues

## Notes

- Uses infrastructure patterns consistent with other applications in this cluster
- Follows GitOps deployment model with ArgoCD
- Integrates with existing PostgreSQL, networking, and secrets management infrastructure
- Optimized for single-node MicroK8s deployment with NFS storage

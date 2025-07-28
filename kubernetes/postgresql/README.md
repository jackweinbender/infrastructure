# PostgreSQL with pgvector

Self-hosted PostgreSQL 16 with pgvector extension and pgAdmin web interface.

## Components

- **PostgreSQL**: `pgvector/pgvector:pg16` with vector similarity search
- **pgAdmin**: Web interface accessible at `pgadmin.k8s.weinbender.io`

## Configuration

### Secrets (1Password Integration)

Passwords are managed via the k8s-secrets-sync operator:

```yaml
annotations:
  "k8s-secrets-sync.weinbender.io/provider": "op"
  "k8s-secrets-sync.weinbender.io/secret-key": "password"
  "k8s-secrets-sync.weinbender.io/ref": "op://microk8s/{item}/password"
```

Required 1Password items:

- `postgresql-db` (database password)
- `pgadmin-web` (web interface password)

### Configuration Management

Non-sensitive configuration is managed via Kustomize ConfigMap generators in `kustomization.yaml`:

- **PostgreSQL settings**: Database user, name, and data directory
- **pgAdmin settings**: Email and server mode configuration
- **Initialization script**: `config/init.sql` for pgvector extension setup
- **Performance tuning**: `config/postgresql.conf` for optimized settings

### Security

- **Security contexts**: Runs as non-root users (101000/110000) matching NFS permissions
- **Capability dropping**: Removes unnecessary Linux capabilities
- **Read-only root filesystem**: Where possible to reduce attack surface

### Storage

Uses hostPath volumes for single-node cluster:

- PostgreSQL data: `/home/nas/shared/pvcs/postgresql-data`
- pgAdmin data: `/home/nas/shared/pvcs/pgadmin-data`

### Backup Infrastructure

Automated daily backups to AWS S3 via Kubernetes CronJob:

- **S3 Bucket**: `k8s-weinbender-io-postgres` (managed via Terraform)
- **Schedule**: Daily at 3am US/Central timezone
- **Method**: `pg_dump` with compression for all databases
- **Retention**: Manual cleanup (no automatic deletion)
- **Storage**: AWS Intelligent Tiering for cost optimization
- **Security**: IAM user with bucket-scoped read/write permissions

The backup infrastructure includes:

- `backup-secrets.yaml`: S3 credentials from 1Password
- `backup-configmap.yaml`: S3 bucket and backup configuration
- `backup-script-configmap.yaml`: Backup script with error handling
- `backup-cronjob.yaml`: Scheduled backup execution

Backup files are stored with timestamp format: `postgres-backup-YYYYMMDD-HHMMSS.sql.gz`

For backup infrastructure setup, see: `terraform/aws/k8s-weinbender-io-postgres.tf`

## Usage

### Database Connection

Connect via service DNS name within cluster:

```
postgresql.postgresql.svc.cluster.local:5432
```

### pgvector Example

```sql
-- Create table with vector column
CREATE TABLE items (
    id serial PRIMARY KEY,
    content text,
    embedding vector(1536)
);

-- Vector similarity search
SELECT content FROM items ORDER BY embedding <-> '[0.1, 0.2, 0.3]' LIMIT 5;
```

## Setup Requirements

1. Create 1Password items with password fields
2. Ensure host directories exist with proper permissions
3. Deploy via ArgoCD

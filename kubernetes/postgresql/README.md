# PostgreSQL with pgvector

Self-hosted PostgreSQL with pgvector extension for vector similarity search.

## Components

- **PostgreSQL**: `pgvector/pgvector:latest` with vector similarity search capabilities

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
- `s3-backup-credentials` (S3 access credentials with `access-key-id` and `secret-access-key` fields)

### Configuration Management

Non-sensitive configuration is managed via Kustomize ConfigMap generators in `kustomization.yaml`:

- **PostgreSQL settings**: Environment variables and data directory configuration
- **Initialization script**: `config/init.sql` for pgvector extension setup
- **Performance tuning**: `config/postgresql.conf` for optimized settings

### Security

- **Security contexts**: Runs as non-root users (101000/110000) matching NFS permissions
- **Capability dropping**: Removes unnecessary Linux capabilities
- **Read-only root filesystem**: Where possible to reduce attack surface

### Storage

Uses hostPath volumes for single-node cluster:

- PostgreSQL data: `/home/nas/shared/pvcs/postgresql-data`

### Backup Infrastructure

Automated daily backups to AWS S3 via Kubernetes CronJob:

- **S3 Bucket**: `k8s-weinbender-io-postgres` (managed via Terraform)
- **Schedule**: Daily at 3am America/Chicago (Central Time)
- **Method**: `pg_dump` with compression for all databases
- **Retention**: Manual cleanup (no automatic deletion)
- **Storage**: AWS Intelligent Tiering for cost optimization
- **Security**: IAM user with bucket-scoped read/write permissions

The backup infrastructure includes:

- `backup-secrets.yaml`: S3 credentials from 1Password (access key ID and secret key)
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

1. Create 1Password items:
   - `postgresql-db` with `password` field
   - `s3-backup-credentials` with `access-key-id` and `secret-access-key` fields
2. Ensure host directories exist with proper permissions (101000:110000)
3. Deploy via ArgoCD

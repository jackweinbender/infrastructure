# Redis Infrastructure

This directory contains the shared Redis deployment for the homelab infrastructure. Redis is configured with authentication and ACL-based user isolation to securely serve multiple applications.

## Overview

- **Single shared instance** for resource efficiency
- **Password + ACL authentication** for security
- **Per-application user isolation** with database separation
- **1Password integration** with **centralized password management**
- **Persistent storage** on NFS-backed volumes

## How Authentication Works

**Password Synchronization Flow:**

1. **1Password**: Stores all user passwords in centralized vaults
2. **k8s-secrets-sync**: Syncs passwords to **both** Redis namespace and application namespaces
3. **Redis Init Container**: Reads passwords from Redis namespace and builds ACL file
4. **Applications**: Read the **same passwords** from their namespace to authenticate

**Key Point**: Both Redis and applications get the **same password** from 1Password, ensuring authentication works.

## Architecture

### Authentication & Authorization

**Admin User:**

- Username: `admin`
- Access: Full Redis access (all commands, all databases)
- Use: Maintenance, monitoring, troubleshooting

**Application Users:**

- Username: `{app-name}` (e.g., `immich`)
- Access: Limited to specific database number
- Restricted: Cannot use dangerous commands
- Isolated: Cannot access other application databases

### Database Allocation

| Database | Application | Status                   |
| -------- | ----------- | ------------------------ |
| 0        | Immich      | ✅ Active                |
| 1        | Available   | 🔄 Reserved for next app |
| 2-15     | Available   | 🔄 Future use            |

## Secrets Management

All Redis passwords are managed via 1Password using the `k8s-secrets-sync` operator:

### Required 1Password Entries

1. **Admin Password:**

   - Vault: `microk8s`
   - Item: `redis`
   - Field: `admin-password`
   - Reference: `op://microk8s/redis/admin-password`

2. **Application Passwords:**
   - Vault: `microk8s`
   - Item: `redis-users`
   - Field: `{app-name}-password` (e.g., `immich-password`)
   - Reference: `op://microk8s/redis-users/{app-name}-password`

## Adding a New Application

### 1. Update Redis ACL Configuration

Edit `configmap.yaml` and add a new user to the `users.acl` section:

```acl
# Example for a new app called "myapp"
user myapp on >MYAPP_PASSWORD_PLACEHOLDER ~* &* +@all -@dangerous +select|2
```

**ACL Breakdown:**

- `user myapp` - Username
- `on` - User is enabled
- `>MYAPP_PASSWORD_PLACEHOLDER` - Password placeholder (replaced at runtime)
- `~*` - Can access any key pattern
- `&*` - Can access any pub/sub channel
- `+@all -@dangerous` - All commands except dangerous ones
- `+select|2` - Can only SELECT database 2

### 2. Create 1Password Entry

Create a new password in 1Password:

- Vault: `microk8s`
- Item: `redis-users`
- Field: `myapp-password`
- Generate a strong password

### 3. Create Secrets in BOTH Namespaces

The **same password** must be available in both the Redis namespace (for ACL configuration) and the application namespace (for authentication).

**In Redis namespace:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: redis-myapp-user
  namespace: redis # Redis namespace
  annotations:
    "k8s-secrets-sync.weinbender.io/provider": "op"
    "k8s-secrets-sync.weinbender.io/secret-key": "password"
    "k8s-secrets-sync.weinbender.io/ref": "op://microk8s/redis-users/myapp-password"
type: Opaque
```

**In Application namespace:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-redis-auth
  namespace: myapp # Your app's namespace
  annotations:
    "k8s-secrets-sync.weinbender.io/provider": "op"
    "k8s-secrets-sync.weinbender.io/secret-key": "password"
    "k8s-secrets-sync.weinbender.io/ref": "op://microk8s/redis-users/myapp-password"
type: Opaque
```

### 4. Update Redis Deployment

Add the new user secret to Redis deployment volumes and init container:

**Add to init container script:**

```bash
sed "s/MYAPP_PASSWORD_PLACEHOLDER/$(cat /secrets/myapp-password/password)/" /tmp/users.acl.tmp2 > /tmp/users.acl.tmp3
```

**Add volume mount:**

```yaml
- name: myapp-password
  mountPath: /secrets/myapp-password
```

**Add volume:**

```yaml
- name: myapp-password
  secret:
    secretName: redis-myapp-user
```

### 5. Configure Application

Configure your application with environment variables:

```yaml
env:
  - name: REDIS_HOSTNAME
    value: "redis.redis.svc.cluster.local"
  - name: REDIS_PORT
    value: "6379"
  - name: REDIS_USERNAME
    value: "myapp"
  - name: REDIS_DBINDEX
    value: "2" # Next available database number
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: myapp-redis-auth
        key: password
```

## Operations

### Connecting to Redis

**As Admin (for troubleshooting):**

```bash
# Get admin password
kubectl get secret redis-auth -n redis -o jsonpath='{.data.password}' | base64 -d

# Connect with password
kubectl exec -it deployment/redis -n redis -- redis-cli -a <admin-password>

# Or using auth command
kubectl exec -it deployment/redis -n redis -- redis-cli
127.0.0.1:6379> AUTH admin <admin-password>
```

**As Application User:**

```bash
kubectl exec -it deployment/redis -n redis -- redis-cli -u redis://immich:<password>@localhost:6379/0
```

### Monitoring

**Check user permissions:**

```bash
# List all users
127.0.0.1:6379> ACL LIST

# Check specific user
127.0.0.1:6379> ACL GETUSER immich
```

**Database usage:**

```bash
# Select database and check info
127.0.0.1:6379> SELECT 0
127.0.0.1:6379> INFO keyspace
```

### Troubleshooting

**Common Issues:**

1. **Authentication failures:**

   - Check if secrets are synced: `kubectl get secrets -n redis`
   - Verify ACL file was created: `kubectl exec deployment/redis -n redis -- cat /etc/redis/users.acl`

2. **Permission denied:**

   - User trying to access wrong database
   - User trying to run restricted commands
   - Check ACL: `ACL GETUSER <username>`

3. **Connection issues:**
   - Verify service: `kubectl get svc redis -n redis`
   - Check pod status: `kubectl get pods -n redis`
   - Review logs: `kubectl logs deployment/redis -n redis`

## Configuration Files

- `configmap.yaml` - Redis configuration and ACL rules
- `secrets.yaml` - User password secrets (1Password managed)
- `deployment.yaml` - Redis deployment with init container
- `service.yaml` - ClusterIP service for internal access
- `kustomization.yaml` - Resource organization

## Security Considerations

- Default user is disabled
- All access requires authentication
- Users isolated to specific databases
- Dangerous commands restricted for app users
- Protected mode enabled
- Secrets managed via 1Password integration

## Storage

- Data persisted to `/home/nas/shared/pvcs/redis`
- NFS-backed storage with proper permissions (101000:110000)
- Redis save configuration for durability

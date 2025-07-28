# PostgreSQL Backup S3 Infrastructure
#
# This file manages the S3 bucket and IAM resources for automated PostgreSQL backups
# from the MicroK8s cluster. The backup system runs as a daily CronJob in the 
# postgresql namespace and uploads compressed database dumps to S3.
#
# Configuration:
# - Bucket: k8s-weinbender-io-postgres
# - Lifecycle: Intelligent Tiering after 1 day for cost optimization
# - Retention: Manual cleanup (no automatic deletion)
# - Access: IAM user with bucket-scoped read/write permissions
# - Security: Public access blocked, encrypted in transit
#
# The backup CronJob runs daily at 3am US/Central and creates timestamped
# SQL dump files that are compressed and uploaded to S3.

# PostgreSQL backup bucket for k8s cluster
resource "aws_s3_bucket" "k8s_postgres_backups" {
  bucket = "k8s-weinbender-io-postgres"
  tags = {
    Project = "infrastructure/kubernetes"
  }
}

# Lifecycle configuration for PostgreSQL backup bucket
resource "aws_s3_bucket_lifecycle_configuration" "k8s_postgres_backups" {
  bucket = aws_s3_bucket.k8s_postgres_backups.id

  rule {
    status = "Enabled"
    id     = "postgres_backup_lifecycle"

    # Move to Intelligent Tiering after 1 day
    transition {
      days          = 1
      storage_class = "INTELLIGENT_TIERING"
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# Block public access (security best practice)
resource "aws_s3_bucket_public_access_block" "k8s_postgres_backups" {
  bucket = aws_s3_bucket.k8s_postgres_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM user for PostgreSQL backup service
resource "aws_iam_user" "k8s_postgres_backup" {
  name = "k8s-postgres-backup-service"
  path = "/service-accounts/"
  tags = {
    Project     = "infrastructure/kubernetes"
    Purpose     = "PostgreSQL backup to S3"
    Environment = "production"
  }
}

# Inline policy for bucket-specific read/write access
resource "aws_iam_user_policy" "k8s_postgres_backup" {
  name = "k8s-postgres-backup-policy"
  user = aws_iam_user.k8s_postgres_backup.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.k8s_postgres_backups.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.k8s_postgres_backups.arn
      }
    ]
  })
}

# Output the bucket name and user details for reference
output "k8s_postgres_backup_bucket" {
  value       = aws_s3_bucket.k8s_postgres_backups.bucket
  description = "S3 bucket name for PostgreSQL backups"
}

output "k8s_postgres_backup_user" {
  value       = aws_iam_user.k8s_postgres_backup.name
  description = "IAM user for PostgreSQL backup service"
}

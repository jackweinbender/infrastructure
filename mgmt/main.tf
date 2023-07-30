resource "random_string" "storage_key" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "aws-backend-bucket" {
  bucket = "tf-backend-${random_string.storage_key.id}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = false
    }
  }
  tags = {
    Project = "infrastructure/mgmt"
  }
}

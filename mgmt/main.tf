resource "random_string" "storage_key" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "aws-backend-bucket" {
  bucket = "tf-backend-${random_string.storage_key.id}"
  tags = {
    Project = "infrastructure/mgmt"
  }
}

resource "aws_s3_bucket_acl" "aws-backend-bucket" {
  bucket = aws_s3_bucket.aws-backend-bucket.id
  acl    = "private"
}
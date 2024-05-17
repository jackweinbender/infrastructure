resource "aws_s3_bucket" "bdb_data" {
  provider = aws.usw2
  bucket   = "bdb-data"
  tags = {
    Project = "infrastructure/primary"
  }
}
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.bdb_data.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket" "bdb_images" {
  bucket = "bdb-images"
  tags = {
    Project = "infrastructure/primary"
  }
}

resource "aws_s3_bucket" "iiif_cache" {
  bucket = "iiifcache"
  tags = {
    Project = "infrastructure/primary"
  }
}

resource "aws_s3_bucket" "weinbender_icloud_photos" {
  provider = aws.usw2
  bucket   = "weinbender-icloud-photos"
  tags = {
    Project = "infrastructure/primary"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "weinbender-icloud-photos" {
  bucket = aws_s3_bucket.weinbender_icloud_photos
  rule {
    status = "enabled"
    id     = "7 Days Intelegent Tiering"
    transition {
      days          = 7
      storage_class = "INTELLIGENT_TIERING"
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 0
    }
  }
}

resource "aws_s3_bucket" "weinbender_photos" {
  bucket = "weinbender-photos"
  tags = {
    Project = "infrastructure/primary"
  }
}


resource "aws_s3_bucket" "weinbender_service_archives" {
  bucket = "weinbender-service-archives"
  tags = {
    Project = "infrastructure/primary"
  }
}
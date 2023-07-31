resource "aws_s3_bucket" "bdb_data" {
  provider = aws.usw2
  bucket   = "bdb-data"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = false
    }
  }
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  tags = {
    Project = "infrastructure/primary"
  }
}

resource "aws_s3_bucket" "bdb_images" {
  bucket = "bdb-images"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = false
    }
  }
  tags = {
    Project = "infrastructure/primary"
  }
}

resource "aws_s3_bucket" "iiif_cache" {
  bucket = "iiifcache"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = false
    }
  }
  tags = {
    Project = "infrastructure/primary"
  }
}

resource "aws_s3_bucket" "weinbender_icloud_photos" {
  provider = aws.usw2
  bucket   = "weinbender-icloud-photos"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }
  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 0
    enabled                                = true
    id                                     = "7 Days Intelegent Tiering"
    tags                                   = {}
    transition {
      days          = 7
      storage_class = "INTELLIGENT_TIERING"
    }
  }
  tags = {
    Project = "infrastructure/primary"
  }
}

resource "aws_s3_bucket" "weinbender_photos" {
  bucket = "weinbender-photos"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = false
    }
  }
  tags = {
    Project = "infrastructure/primary"
  }
}


resource "aws_s3_bucket" "weinbender_service_archives" {
  bucket = "weinbender-service-archives"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = false
    }
  }
  tags = {
    Project = "infrastructure/primary"
  }
}
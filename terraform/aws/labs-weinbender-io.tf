data "aws_route53_zone" "weinbender_io" {
  name = "weinbender.io"
}

resource "aws_s3_bucket" "labs" {
  bucket = "labs-weinbender-io"
  tags = {
    Project = "infrastructure/aws"
  }
}

resource "aws_s3_bucket_public_access_block" "labs" {
  bucket                  = aws_s3_bucket.labs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "labs" {
  name                              = "labs-weinbender-io"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_acm_certificate" "labs" {
  domain_name       = "labs.weinbender.io"
  validation_method = "DNS"
  tags = {
    Project = "infrastructure/aws"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "labs_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.labs.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.weinbender_io.zone_id
}

resource "aws_acm_certificate_validation" "labs" {
  certificate_arn         = aws_acm_certificate.labs.arn
  validation_record_fqdns = [for record in aws_route53_record.labs_cert_validation : record.fqdn]
}

resource "aws_cloudfront_distribution" "labs" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["labs.weinbender.io"]

  origin {
    domain_name              = aws_s3_bucket.labs.bucket_regional_domain_name
    origin_id                = "labs-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.labs.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "labs-s3"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.labs.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Project = "infrastructure/aws"
  }

  depends_on = [aws_acm_certificate_validation.labs]
}

resource "aws_s3_bucket_policy" "labs" {
  bucket = aws_s3_bucket.labs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.labs.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.labs.arn
          }
        }
      }
    ]
  })
}

resource "aws_route53_record" "labs_a" {
  zone_id = data.aws_route53_zone.weinbender_io.zone_id
  name    = "labs.weinbender.io"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.labs.domain_name
    zone_id                = aws_cloudfront_distribution.labs.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "labs_aaaa" {
  zone_id = data.aws_route53_zone.weinbender_io.zone_id
  name    = "labs.weinbender.io"
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.labs.domain_name
    zone_id                = aws_cloudfront_distribution.labs.hosted_zone_id
    evaluate_target_health = false
  }
}

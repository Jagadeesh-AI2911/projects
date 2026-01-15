#s3 bucket for static bucket 
resource "aws_s3_bucket" "static" {
    bucket          = "${var.app_name}-${var.environment}-static-assets"
    force_destroy   = var.environment == "dev" ? true : false
}

resource "aws_s3_bucket_public_access_block" "block" {
    bucket                  = aws_s3_bucket.static.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "default" {
    name                                = "${var.app_name}-${var.environment}-oac"
    description                         = "granting cloudfront access to s3"
    origin_access_control_origin_type   = "s3"
    signing_behavior                    = "always"
    signing_protocol                    = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Price Class: Use PriceClass_100 (USA/Europe only) for Dev to save money
  price_class = var.environment == "dev" ? "PriceClass_100" : "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = {
    Environment = var.environment
  }
}
resource "aws_s3_bucket_policy" "allow_cloudfront" {
    bucket = "aws_s3_bucket.static.id"
    policy = jsonencode ({
        Version     = "2012-10-17"
        Statement   = [
            {
                Sid         = "AllowCloudFrontServicePrincipal"
                Effect      = "Allow"
                Principal   = {
                    Service     = "cloudfront.amazonaws.com"
                }
                Action      = "s3:GetObject"
                Resource    = "${aws_s3_bucket.static.arn}/*"
                Condition   = {
                    StringEquals = {
                        "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
                    }
                }
            }
        ]
    })
}
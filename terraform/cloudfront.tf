# ---------------------------------------------------------------------------
# cloudfront.tf
# CloudFront Distribution + Origin Access Control (OAC)
# Architecture: Browser → CloudFront → OAC → S3 (Private)
# NOTE: Running without a custom domain — using CloudFront default certificate.
#       To attach a custom domain later, see the commented sections below.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Origin Access Control (OAC)
# ---------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.domain_name}-oac"
  description                       = "OAC for ${var.domain_name} S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ---------------------------------------------------------------------------
# CloudFront Distribution
# ---------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "Resume-as-Code CDN for ${var.domain_name}"
  price_class         = "PriceClass_100"

  # --- Uncomment when you have a custom domain + ACM cert ---
  # aliases = [var.domain_name, "www.${var.domain_name}"]

  # --- Origin: Private S3 Bucket via OAC ---
  origin {
    domain_name              = aws_s3_bucket.resume.bucket_regional_domain_name
    origin_id                = "S3-${var.domain_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # --- Default Cache Behaviour ---
  default_cache_behavior {
    target_origin_id       = "S3-${var.domain_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # AWS Managed: CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 604800
  }

  # --- Custom Error Responses ---
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 10
  }

  # --- Certificate ---
  # Using CloudFront default certificate (no custom domain required).
  # Uncomment the acm block and comment out cloudfront_default_certificate
  # when you're ready to attach a custom domain.
  viewer_certificate {
    cloudfront_default_certificate = true

    # --- Uncomment when you have a custom domain + ACM cert ---
    # acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    # ssl_support_method       = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2021"
  }

  # --- Geo Restrictions ---
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Project     = "resume-as-code"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

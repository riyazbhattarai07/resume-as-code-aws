# ---------------------------------------------------------------------------
# cloudfront.tf
# CloudFront Distribution + Origin Access Control (OAC)
# Architecture: Browser → Route 53 + ACM → CloudFront → OAC → S3 (Private)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Origin Access Control (OAC)
# Replaces the legacy OAI — restricts S3 bucket access to CloudFront only.
# Prevents direct public access to the S3 origin (no "S3 bucket leak").
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
# Serves the private S3 bucket via OAC with HTTPS enforced.
# ACM certificate is created and validated in dns.tf — referenced directly
# via aws_acm_certificate_validation.cert.certificate_arn (no manual ARN needed).
# ---------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.domain_name, "www.${var.domain_name}"]
  comment             = "Resume-as-Code CDN for ${var.domain_name}"

  # Limits edge locations to US, Canada, Europe — lowest cost tier.
  # Remove this line or set to "PriceClass_All" for global delivery.
  price_class = "PriceClass_100"

  # --- Origin: Private S3 Bucket via OAC ---
  origin {
    domain_name              = aws_s3_bucket.resume.bucket_regional_domain_name
    origin_id                = "S3-${var.domain_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # --- Default Cache Behaviour ---
  # FIX: replaced deprecated forwarded_values with AWS managed CachingOptimized
  # policy (658327ea-f89d-4fab-a63d-7e88639e58f6) — recommended for static S3 origins.
  default_cache_behavior {
    target_origin_id       = "S3-${var.domain_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # AWS Managed: CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    # Extended TTL — resume rarely changes. Bust cache on deploy with:
    # aws cloudfront create-invalidation --distribution-id <id> --paths "/*"
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 604800 # 7 days
  }

  # --- Custom Error Responses ---
  # FIX: removed SPA-style 200 rewrites — not appropriate for a static site.
  # S3 returns 403 for missing objects on private buckets; map both to a real
  # 404 so clients and search engines get the correct status code.
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

  # --- ACM SSL Certificate (must be in us-east-1) ---
  # FIX: references the cert created and validated in dns.tf directly —
  # removes the need for the acm_certificate_arn input variable entirely.
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # --- Geo Restrictions (none — global delivery) ---
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

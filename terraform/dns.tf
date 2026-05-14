# ---------------------------------------------------------------------------
# dns.tf
# Route 53 DNS records and ACM certificate validation.
# Architecture: Browser → Route 53 (DNS) + ACM (SSL) → CloudFront
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Fetch the existing Route 53 Hosted Zone for the domain
# Assumes the domain is already registered and managed in Route 53.
# ---------------------------------------------------------------------------
data "aws_route53_zone" "primary" {
  name         = var.domain_name
  private_zone = false
}

# ---------------------------------------------------------------------------
# ACM Certificate
# Must be provisioned in us-east-1 — hard requirement for CloudFront.
# Uses DNS validation (recommended over email validation).
# ---------------------------------------------------------------------------
resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "www.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project     = "resume-as-code"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# ACM DNS Validation Records
# Creates the CNAME records Route 53 needs to validate the certificate.
# ---------------------------------------------------------------------------
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# ---------------------------------------------------------------------------
# Wait for ACM certificate validation to complete
# ---------------------------------------------------------------------------
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# ---------------------------------------------------------------------------
# Route 53 A Record (Apex domain) → CloudFront
# ---------------------------------------------------------------------------
resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# ---------------------------------------------------------------------------
# Route 53 A Record (www) → CloudFront
# ---------------------------------------------------------------------------
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

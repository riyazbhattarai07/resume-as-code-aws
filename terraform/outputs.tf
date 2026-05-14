# ---------------------------------------------------------------------------
# outputs.tf
# Useful resource endpoints printed after terraform apply.
# ---------------------------------------------------------------------------

output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (useful for cache invalidation)"
  value       = aws_cloudfront_distribution.cdn.id
}

output "s3_bucket_name" {
  description = "Name of the private S3 bucket"
  value       = aws_s3_bucket.resume.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the private S3 bucket"
  value       = aws_s3_bucket.resume.arn
}

output "website_url" {
  description = "Live website URL"
  value       = "https://${var.domain_name}"
}

output "acm_certificate_arn" {
  description = "ARN of the ACM SSL certificate"
  value       = aws_acm_certificate.cert.arn
}

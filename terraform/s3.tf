# ---------------------------------------------------------------------------
# s3.tf
# Private S3 bucket for static website hosting.
# Bucket is NOT public — access is granted exclusively to CloudFront via OAC.
# This directly prevents the common "S3 bucket leak" vulnerability.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# S3 Bucket
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "resume" {
  bucket = var.domain_name

  tags = {
    Project     = "resume-as-code"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# Block all public access — content is served only through CloudFront
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "resume" {
  bucket = aws_s3_bucket.resume.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------------------
# Bucket versioning (optional but good practice)
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_versioning" "resume" {
  bucket = aws_s3_bucket.resume.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------------------------------------------------------------------
# S3 Bucket Policy — Allow CloudFront OAC to read objects
# Denies all other access, including direct public requests.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "resume" {
  bucket = aws_s3_bucket.resume.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOACReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.resume.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.resume]
}

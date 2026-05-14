# ---------------------------------------------------------------------------
# variables.tf
# Input variables for the Resume-as-Code AWS infrastructure.
# ---------------------------------------------------------------------------

variable "domain_name" {
  description = "The root domain name managed in Route 53 (e.g. riyaz.dev)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM SSL certificate provisioned in us-east-1 (required for CloudFront)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for all resources except ACM (which must be us-east-1)"
  type        = string
  default     = "us-east-1"
}

# ---------------------------------------------------------------------------
# variables.tf
# Input variables for the Resume-as-Code AWS infrastructure.
# ---------------------------------------------------------------------------

variable "domain_name" {
  description = "The root domain name managed in Route 53 (e.g. apple.dev)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for all resources except ACM (which must be us-east-1)"
  type        = string
  default     = "us-east-1"
}

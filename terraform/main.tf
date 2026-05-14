# ---------------------------------------------------------------------------
# main.tf
# AWS provider configuration and Terraform version constraints.
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote Backend (optional — recommended for team environments)
  # Uncomment and configure to store state in S3 with DynamoDB state locking.
  # ---------------------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "resume-as-code/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

# Default provider
provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------
# us-east-1 provider alias
# Required for ACM certificate — CloudFront only accepts certs from us-east-1.
# ---------------------------------------------------------------------------
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

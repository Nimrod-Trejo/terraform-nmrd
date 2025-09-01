terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }

  # Configure remote state in S3 using an external backend config file (backend.hcl)
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
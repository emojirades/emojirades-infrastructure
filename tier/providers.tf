terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

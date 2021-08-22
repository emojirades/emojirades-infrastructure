terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.50"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"
}

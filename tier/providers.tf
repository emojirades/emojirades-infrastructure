terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  required_providers {
    aws = {
      source  = "-/aws"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"
}

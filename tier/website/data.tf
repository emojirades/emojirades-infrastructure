# Account Resources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Environment Resources
data "aws_route53_zone" "environment_zone" {
  name = "${local.environment_zone}"
}

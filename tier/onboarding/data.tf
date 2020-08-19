# Environment Resources
data "aws_route53_zone" "environment_zone" {
  name = "${local.environment_zone}"
}

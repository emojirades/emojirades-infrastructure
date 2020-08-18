resource "aws_route53_zone" "environment" {
  name = local.environment_zone

  tags = local.tier_tags
}

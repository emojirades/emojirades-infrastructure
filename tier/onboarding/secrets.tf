resource "aws_secretsmanager_secret" "onboarding" {
  name = "${local.prefix}-onboarding"
  tags = local.tier_tags
}

data "aws_secretsmanager_secret_version" "onboarding" {
  secret_id = aws_secretsmanager_secret.onboarding.id
}

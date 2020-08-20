locals {
  default_onboarding_secret = {
    "CLIENT_ID": "",
    "CLIENT_SECRET": "",
    "SCOPE": "",
  }
}

resource "aws_secretsmanager_secret" "onboarding" {
  name = "${local.prefix}-onboarding"
  tags = local.tier_tags
}

resource "aws_secretsmanager_secret_version" "onboarding" {
  secret_id     = aws_secretsmanager_secret.onboarding.id
  secret_string = jsonencode(local.default_onboarding_secret)
}

resource "aws_cloudwatch_log_group" "onboarding" {
  name = "/aws/lambda/${local.onboarding_lambda_name}"
  tags = local.tier_tags

  retention_in_days = 30
}

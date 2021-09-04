# Onboarding Service
locals {
  onboarding_lambda_timeout = 60
  onboarding_lambda_name = "${local.prefix}-onboarding-service"
}

resource "aws_dynamodb_table" "onboarding" {
  name           = "${local.prefix}-onboarding"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  hash_key  = "StateKey"

  attribute {
    name = "StateKey"
    type = "S"
  }

  ttl {
    attribute_name = "StateTTL"
    enabled        = true
  }

  tags = local.tier_tags
}

resource "aws_sqs_queue" "onboarding_dlq" {
  count = lookup(var.tier_config, "bot_shard_count")

  name = "${local.prefix}-onboarding-service-dlq-shard-${count.index}"

  tags = local.tier_tags
}

resource "aws_sqs_queue" "onboarding" {
  count = lookup(var.tier_config, "bot_shard_count")

  name          = "${local.prefix}-onboarding-service-shard-${count.index}"
  delay_seconds = 5

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.onboarding_dlq[count.index].arn
    maxReceiveCount     = 2
  })

  tags = local.tier_tags
}

resource "aws_sqs_queue" "alerts_dlq" {
  name = "${local.prefix}-onboarding-service-alerts-dlq"

  tags = local.tier_tags
}

resource "aws_sqs_queue" "alerts" {
  name = "${local.prefix}-onboarding-service-alerts"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.alerts_dlq.arn
    maxReceiveCount     = 1
  })

  tags = local.tier_tags
}

resource "aws_lambda_function" "onboarding" {
  function_name = local.onboarding_lambda_name
  description   = "Onboarding Service"

  s3_bucket = local.emojirades_bucket
  s3_key    = lookup(var.tier_config, "function_s3_key")
  handler   = "handler.lambda_handler"

  runtime = "python3.8"

  timeout      = local.onboarding_lambda_timeout
  memory_size  = 128

  environment {
    variables = {
      ENVIRONMENT     = local.environment
      SECRET_NAME     = data.aws_secretsmanager_secret_version.onboarding.arn
      STATE_TABLE     = aws_dynamodb_table.onboarding.id
      CONFIG_BUCKET   = local.emojirades_bucket
      QUEUE_PREFIX    = "${local.prefix}-onboarding-service-shard-"
      SHARD_LIMIT     = lookup(var.tier_config, "shard_limit")
      ALERT_QUEUE_URL = aws_sqs_queue.alerts.id
    }
  }

  role = aws_iam_role.onboarding_permissions.arn

  tags = local.tier_tags
}

resource "aws_lambda_permission" "onboarding_execute" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.onboarding.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.onboarding.execution_arn}/*/*"
}

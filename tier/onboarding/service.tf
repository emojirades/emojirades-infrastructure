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
  name = "${local.prefix}-onboarding-service-dlq"

  tags = local.tier_tags
}

resource "aws_sqs_queue" "onboarding" {
  name = "${local.prefix}-onboarding-service"

  delay_seconds              = 5
  visibility_timeout_seconds = local.onboarding_lambda_timeout * 2

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.onboarding_dlq.arn
    maxReceiveCount     = 2
  })

  tags = local.tier_tags
}

resource "aws_lambda_function" "onboarding" {
	function_name = local.onboarding_lambda_name
  description   = "Onboarding Service"

  s3_bucket = local.emojirades_bucket
  s3_key    = "functions/onboarding-service.zip"
  handler   = "handler.lambda_handler"

  runtime = "python3.8"

  timeout      = local.onboarding_lambda_timeout
  memory_size  = 128

  environment {
    variables = {
      ENVIRONMENT = local.environment
      SECRET_ARN  = data.aws_secretsmanager_secret_version.onboarding.arn
      STATE_TABLE = aws_dynamodb_table.onboarding.id
      AUTH_BUCKET = local.emojirades_bucket
      QUEUE_URL   = aws_sqs_queue.onboarding.id
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

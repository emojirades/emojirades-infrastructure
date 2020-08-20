# Onboarding Service
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

resource "aws_lambda_function" "onboarding" {
	function_name = "${local.prefix}-onboarding-service"
  description   = "Onboarding Service"

  s3_bucket = local.onboarding_bucket
  s3_key    = "onboarding_service.zip"
  handler   = "handler.lambda_handler"

  runtime = "python3.8"

  timeout      = 60
  memory_size  = 128

  environment {
    variables = {
      ENVIRONMENT   = local.environment
      CLIENT_ID     = jsondecode(aws_secretsmanager_secret_version.onboarding.secret_string)["CLIENT_ID"]
      CLIENT_SECRET = jsondecode(aws_secretsmanager_secret_version.onboarding.secret_string)["CLIENT_SECRET"]
      SCOPE         = jsondecode(aws_secretsmanager_secret_version.onboarding.secret_string)["SCOPE"]
      STATE_TABLE   = aws_dynamodb_table.onboarding.id
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

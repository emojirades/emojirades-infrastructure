locals {
  onboarding_bucket = local.environment == "prod" ? "emojirades" : "emojirades-${local.environment}"
}

# Onboarding Certificate
resource "aws_acm_certificate" "onboarding" {
  domain_name       = "onboarding.${local.environment_zone}"
  validation_method = "DNS"

  tags = merge(local.tier_tags, {"Name": "${local.prefix}-onboarding-certificate"})

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "onboarding_validation" {
  for_each = {
    for dvo in aws_acm_certificate.onboarding.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.environment_zone.zone_id
}


# Onboarding API
resource "aws_apigatewayv2_domain_name" "onboarding" {
  domain_name = "onboarding.${local.environment_zone}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.onboarding.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = local.tier_tags
}

resource "aws_route53_record" "onboarding" {
  name    = aws_apigatewayv2_domain_name.onboarding.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.environment_zone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.onboarding.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.onboarding.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api" "onboarding" {
  name        = "${local.prefix}-onboarding-api"
  description = "Emojirades Onboarding Service"

  protocol_type = "HTTP"
  target        = aws_lambda_function.onboarding.arn

  tags = local.tier_tags
}

resource "aws_apigatewayv2_stage" "onboarding" {
  api_id = aws_apigatewayv2_api.onboarding.id
  name   = local.prefix

  tags = local.tier_tags
}

resource "aws_apigatewayv2_api_mapping" "onboarding" {
  api_id      = aws_apigatewayv2_api.onboarding.id
  domain_name = aws_apigatewayv2_domain_name.onboarding.id
  stage       = aws_apigatewayv2_stage.onboarding.id
}


# Onboarding Service
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

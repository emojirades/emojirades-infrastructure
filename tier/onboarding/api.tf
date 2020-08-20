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

resource "aws_apigatewayv2_api_mapping" "onboarding" {
  api_id      = aws_apigatewayv2_api.onboarding.id
  domain_name = aws_apigatewayv2_domain_name.onboarding.id
  stage       = "$default"
}

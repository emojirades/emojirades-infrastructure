resource "aws_cloudfront_distribution" "website" {
  http_version = "http2"

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_domain_name
    origin_id   = "S3-${aws_s3_bucket.website_bucket.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Emojirades Website"
  default_root_object = "index.html"

  custom_error_response {
    error_code            = "403"
    error_caching_min_ttl = "300"
    response_code         = "404"
    response_page_path    = "/404.html"
  }

  aliases = [
    var.tier_config["website_bucket"],
    var.tier_config["www_website_bucket"],
  ]

  default_cache_behavior {
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.id}"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.environment_tags
}

resource "aws_acm_certificate" "website_cert" {
  provider = aws.us-east-1

  domain_name = var.tier_config["website_bucket"]

  subject_alternative_names = [
    "*.${var.tier_config["website_bucket"]}",
  ]

  validation_method = "DNS"

  tags = local.environment_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "website_cert_dns" {
  for_each = {
    for dvo in aws_acm_certificate.website_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.environment_zone.zone_id
}

resource "aws_acm_certificate_validation" "website_cert_validation" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.website_cert_dns : record.fqdn]
}

locals {
  region    = lookup(var.tier_config, "workmail_region")
  dkim_keys = lookup(var.tier_config, "dkim_keys")
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.environment.zone_id
  name    = local.environment_zone
  type    = "MX"
  ttl     = "300"
  records = ["10 inbound-smtp.${local.region}.amazonaws.com."]
}

resource "aws_route53_record" "autodiscover" {
  zone_id = aws_route53_zone.environment.zone_id
  name    = "autodiscover.${local.environment_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["autodiscover.mail.${local.region}.awsapps.com."]
}

resource "aws_route53_record" "ses_verify" {
  zone_id = aws_route53_zone.environment.zone_id
  name    = "_amazonses.${local.environment_zone}"
  type    = "TXT"
  ttl     = "300"
  records = ["q6OV2SrZUgLdpDqjQols+G3v6LEOa26DylxVdX7/dAs="]
}

resource "aws_route53_record" "dkim_record" {
  for_each = toset(local.dkim_keys)

  zone_id = aws_route53_zone.environment.zone_id
  name    = "${each.key}._domainkey.${local.environment_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${each.key}.dkim.amazonses.com."]
}

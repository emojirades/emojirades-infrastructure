resource "aws_route53_record" "github_verify" {
  zone_id = aws_route53_zone.environment.zone_id
  name    = "_github-challenge-emojirades.${local.environment_zone}"
  type    = "TXT"
  ttl     = "300"
  records = ["fe2a200c21"]
}

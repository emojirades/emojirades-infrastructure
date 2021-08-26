resource "aws_iam_user" "website_deployer" {
  name = "${local.prefix}-website-deployer"

  tags = local.tier_tags
}

resource "aws_iam_user_policy" "website_deployer" {
  name = "${local.prefix}-website-deployer"
  user = aws_iam_user.website_deployer.name

  policy = data.aws_iam_policy_document.website_deployer.json
}

data "aws_iam_policy_document" "website_deployer" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.website_bucket.arn}/*",
    ]
  }
}

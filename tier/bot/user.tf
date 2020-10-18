# Bot User
resource "aws_iam_user" "bot" {
  name = "${local.prefix}-bot-user"

  tags = local.tier_tags
}

resource "aws_iam_user_policy" "bot_permissions" {
  name = "${local.prefix}-bot-permissions"
  user = aws_iam_user.bot.name

  policy = data.aws_iam_policy_document.bot_permissions_policy.json
}

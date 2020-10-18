# Bot Permissions
data "aws_iam_policy_document" "bot_permissions_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${local.emojirades_bucket}/workspaces/*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.emojirades_bucket}",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "workspaces/*",
      ]
    }
  }

  statement {
    actions = [
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
    ]

    resources = [
      "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${local.prefix}-onboarding-service-shard-*"
    ]
  }
}

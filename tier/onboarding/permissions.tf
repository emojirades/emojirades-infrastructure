# Onboarding Service Permissions
data "aws_iam_policy_document" "onboarding_permissions_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "onboarding_permissions" {
  name               = "${local.prefix}-onboarding-role"
  assume_role_policy = data.aws_iam_policy_document.onboarding_permissions_assume.json

  tags = local.tier_tags
}

data "aws_iam_policy_document" "onboarding_permissions_policy" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${local.emojirades_bucket}/workspaces/*",
    ]
  }

  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
    ]

    resources = [
      aws_dynamodb_table.onboarding.arn,
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      data.aws_secretsmanager_secret_version.onboarding.arn
    ]
  }

  statement {
    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      aws_sqs_queue.onboarding.arn
    ]
  }
}

resource "aws_iam_role_policy" "onboarding_permissions" {
  name = "${local.prefix}-onboarding-policy"
  role = aws_iam_role.onboarding_permissions.id

  policy = data.aws_iam_policy_document.onboarding_permissions_policy.json
}

resource "aws_iam_role_policy_attachment" "onboarding_logging_permissions" {
  role       = aws_iam_role.onboarding_permissions.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

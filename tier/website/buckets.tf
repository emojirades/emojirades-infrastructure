# Website buckets
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.tier_config["website_bucket"]
  acl    = "public-read"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = local.tier_tags
}

resource "aws_s3_bucket_public_access_block" "website_bucket_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "website_bucket_policy" {
  statement {
    sid = "PublicReadForGetBucketObjects"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.website_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = data.aws_iam_policy_document.website_bucket_policy.json
}

resource "aws_s3_bucket" "www_website_bucket" {
  bucket = var.tier_config["www_website_bucket"]
  acl    = "public-read"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  website {
    redirect_all_requests_to = "https://${var.tier_config["website_bucket"]}"
  }

  tags = local.tier_tags
}

resource "aws_s3_bucket_public_access_block" "www_website_bucket_access" {
  bucket = aws_s3_bucket.www_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

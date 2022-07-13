# SNS Policies

data "aws_iam_policy_document" "common_tre_slack_alerts_sns_topic_policy" {
  statement {
    actions = [ "sns:Publish" ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = var.sfn_role_arns 
    }
    resources = [ aws_sns_topic.common_tre_slack_alerts.arn ]
  }
}

data "aws_iam_policy_document" "common_tre_in_topic_policy" {
  statement {
    actions = [ "sns:Publish" ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = var.sfn_role_arns
    }
    resources = [ aws_sns_topic.common_tre_in.arn ]
  }
}


# Lambda Policies

resource "aws_iam_role" "common_tre_slack_alerts_lambda_role" {
  name = "${var.env}-${var.prefix}-common-slack-alerts-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "common_tre_slack_alerts_policy" {
  role = aws_iam_role.common_tre_slack_alerts_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

# S3 Policy

data "aws_iam_policy_document" "common_tre_data_bucket" {
  statement {
    actions = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", ]

    principals {
      type        = "AWS"
      identifiers = var.sfn_lambda_roles
    }

    resources = ["${aws_s3_bucket.common_tre_data.arn}/*", aws_s3_bucket.common_tre_data.arn]
  }
}

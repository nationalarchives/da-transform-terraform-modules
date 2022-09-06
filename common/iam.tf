# SNS Policies

data "aws_iam_policy_document" "common_tre_slack_alerts_sns_topic_policy" {
  statement {
    actions = ["sns:Publish"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.tre_slack_alerts_publishers
    }
    resources = [aws_sns_topic.common_tre_slack_alerts.arn]
  }
}

data "aws_iam_policy_document" "tre_in_topic_policy" {
  statement {
    sid     = "TRE-InPublishers"
    actions = ["sns:Publish"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.tre_in_publishers
    }
    resources = [aws_sns_topic.tre_in.arn]
  }
}

data "aws_iam_policy_document" "tre_out_topic_policy" {
  statement {
    sid     = "TRE-OutPublishers"
    actions = ["sns:Publish"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.tre_out_publishers
    }
    resources = [aws_sns_topic.tre_out.arn]
  }
}

data "aws_iam_policy_document" "tre_internal_topic_policy" {
  statement {
    sid     = "TRE-InternalPublishers"
    actions = ["sns:Publish"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.tre_internal_publishers
    }
    resources = [aws_sns_topic.tre_internal.arn]
  }
}


# Lambda Policies

resource "aws_iam_role" "common_tre_slack_alerts_lambda_role" {
  name               = "${var.env}-${var.prefix}-common-slack-alerts-lambda-role"
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
  role       = aws_iam_role.common_tre_slack_alerts_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

resource "aws_iam_role" "tre_forward_lambda_role" {
  name               = "${var.env}-${var.prefix}-forward-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "tre_forward_lambda_sqs_exec_policy" {
  role       = aws_iam_role.tre_forward_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy_attachment" "tre_forward_lambda_xray_policy" {
  role       = aws_iam_role.tre_forward_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}
# S3 Policy

data "aws_iam_policy_document" "common_tre_data_bucket" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    principals {
      type        = "AWS"
      identifiers = var.tre_data_bucket_write_access
    }

    resources = ["${aws_s3_bucket.common_tre_data.arn}/*", aws_s3_bucket.common_tre_data.arn]
  }
}

# SQS Policy

data "aws_iam_policy_document" "tre_forward_queue" {
  statement {
    actions = ["sqs:SendMessage"]
    effect  = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }

    resources = [
      aws_sqs_queue.tre_forward.arn
    ]
  }
}
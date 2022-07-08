# SNS Policies

data "aws_iam_policy_document" "common_tre_slack_alerts_sns_topic_policy" {
  statement {
    actions = [ "sns:Publish" ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = var.sfn_arns 
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
      identifiers = var.sfn_arns
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

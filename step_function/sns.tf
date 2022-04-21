resource "aws_sns_topic" "editorial_sns" {
  name              = "${var.env}-${var.prefix}-editorial-out"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "editorial_sns_policy" {
  arn    = aws_sns_topic.editorial_sns.arn
  policy = data.aws_iam_policy_document.editorial_sns_topic_policy.json
}


# TRE Slack Alerts SNS

resource "aws_sns_topic" "tre_slack_alerts" {
  name              = "${var.env}-${var.prefix}-slack-alerts"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "tre_slack_alerts_sns_policy" {
  arn    = aws_sns_topic.tre_slack_alerts.arn
  policy = data.aws_iam_policy_document.tre_slack_alerts_sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "tre_slack_alerts_lambda_subscription" {
  topic_arn = aws_sns_topic.tre_slack_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.tre_slack_alerts_function.arn
}
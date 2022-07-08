resource "aws_sns_topic" "common_tre_slack_alerts" {
  name = "${var.env}-${var.prefix}-common-slack-alerts"
  kms_master_key_id = "alias/aws/sns" 
}

resource "aws_sns_topic_policy" "common_tre_slack_alerts" {
  arn = aws_sns_topic.common_tre_slack_alerts.arn
  policy = data.aws_iam_policy_document.common_tre_slack_alerts_sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "common_tre_slack_alerts" {
  topic_arn = aws_lambda_function.common_tre_slack_alerts.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.common_tre_slack_alerts.arn
}

output "common_tre_slack_alerts_topic_arn" {
  value = aws_sns_topic.common_tre_slack_alerts.arn
  description = "ARN of the Common TRE Slack Alerts"
}

# TRE In SNS Topic

resource "aws_sns_topic" "common_tre_in" {
  name = "${var.env}-${var.prefix}-common-tre-in"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "common_tre_in" {
  arn = aws_sns_topic.common_tre_in.arn
  policy = data.aws_iam_policy_document.common_tre_in_topic_policy.json
}

output "common_tre_in_sns_topic_arn" {
  value = aws_sns_topic.common_tre_in.arn
}

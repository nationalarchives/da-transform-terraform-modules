resource "aws_lambda_function" "common_tre_slack_alerts" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-slack-alerts:${var.image_versions.tre_slack_alerts}"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-common-slack-alerts"
  role = aws_iam_role.common_tre_slack_alerts_lambda_role.arn
  timeout = 30
  environment {
    variables = {
      "SLACK_WEBHOOK_URL" = var.slack_webhook_url
      "ENV" = var.env
      "SLACK_CHANNEL" = var.slack_channel
      "SLACK_USERNAME" = var.slack_username
    }
  }

  tags = {
    "ApplicationType" = "Python"
  }
}

resource "aws_lambda_permission" "common_tre_slakc_alerts_sns_trigger_permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.common_tre_slack_alerts.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.common_tre_slack_alerts.arn
}

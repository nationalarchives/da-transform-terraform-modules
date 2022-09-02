resource "aws_lambda_function" "common_tre_slack_alerts" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-slack-alerts:${var.common_image_versions.tre_slack_alerts}"
  package_type  = "Image"
  function_name = "${var.env}-${var.prefix}-common-slack-alerts"
  role          = aws_iam_role.common_tre_slack_alerts_lambda_role.arn
  timeout       = 30
  environment {
    variables = {
      "SLACK_WEBHOOK_URL" = var.slack_webhook_url
      "ENV"               = var.env
      "SLACK_CHANNEL"     = var.slack_channel
      "SLACK_USERNAME"    = var.slack_username
    }
  }

  tags = {
    "ApplicationType" = "Python"
  }
}

resource "aws_lambda_permission" "common_tre_slack_alerts_sns_trigger_permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.common_tre_slack_alerts.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.common_tre_slack_alerts.arn
}

# TRE-Forward Lambda

resource "aws_lambda_function" "tre_forward" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-forward:${var.common_image_versions.tre_forward}"
  package_type  = "Image"
  function_name = "${var.env}-${var.prefix}-forward"
  role          = aws_iam_role.tre_forward_lambda_role.arn
  timeout       = 30
  environment {
    variables = {
      "TRE_OUT_TOPIC_ARN" = aws_sqs_queue.tre_forward.arn
    }
  }
  tracing_config {
    mode = "Active"
  }

  tags = {
    "ApplicationType" = "Python"
  }
}

resource "aws_lambda_event_source_mapping" "vb_in_sqs" {
  batch_size                         = 3
  function_name                      = aws_lambda_function.tre_forward.function_name
  event_source_arn                   = aws_sqs_queue.tre_forward.arn
  maximum_batching_window_in_seconds = 0
}

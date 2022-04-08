resource "aws_lambda_function" "tdr_message_function" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-step-function-trigger:${var.image_version.version.te_step_function_trigger}"
  package_type  = "Image"
  function_name = "${var.env}-${var.prefix}-step-function-trigger"
  role          = aws_iam_role.tdr_message_lambda_role.arn
  timeout       = 30

  environment {
    variables = {
      SFN_ARN = "${var.sfn_arn}"
    }
  }
  tags = {
    ApplicationType = "Python"
  }
}

resource "aws_lambda_event_source_mapping" "tdr_message_sqs" {
  batch_size                         = 3
  function_name                      = aws_lambda_function.tdr_message_function.function_name
  event_source_arn                   = aws_sqs_queue.tdr_message_queue.arn
  maximum_batching_window_in_seconds = 0
}

resource "aws_lambda_event_source_mapping" "editorial_message_sqs" {
  batch_size                         = 3
  function_name                      = aws_lambda_function.tdr_message_function.function_name
  event_source_arn                   = aws_sqs_queue.editorial_message_queue.arn
  maximum_batching_window_in_seconds = 0
}



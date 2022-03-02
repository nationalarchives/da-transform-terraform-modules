resource "aws_lambda_function" "tdr_message_function" {
  image_uri = "882876621099.dkr.ecr.eu-west-2.amazonaws.com/te-step-function-trigger:latest"
  package_type = "Image"
  function_name = "${var.env}-tdr-sqs-message"
  role = aws_iam_role.tdr_message_lambda_role.arn
  timeout = 30

  environment {
    variables = {
      SFN_ARN = "${var.sfn_arn}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "tdr_message_sqs" {
    batch_size = 3
    function_name = aws_lambda_function.tdr_message_function.function_name
    event_source_arn = aws_sqs_queue.tdr_message_queue.arn
    maximum_batching_window_in_seconds = 0
}




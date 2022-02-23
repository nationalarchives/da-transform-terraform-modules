data "archive_file" "tdr_message_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/tdr_message.py"
  output_path = "./tdr_message.zip"
}

resource "aws_lambda_function" "tdr_message_function" {
  filename = data.archive_file.tdr_message_lambda_zip.output_path
  function_name = "${var.env}-tdr-sqs-message"
  role = aws_iam_role.tdr_message_lambda_role.arn
  handler = "tdr_message.lambda_handler"
  source_code_hash = data.archive_file.tdr_message_lambda_zip.output_base64sha256
  runtime = "python3.8"
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




resource "aws_sqs_queue" "tre_forward" {
  name = "${var.env}-${var.prefix}-forward"
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.tre_forward_deadletter.arn}"
    maxReceiveCount     = 5
  })
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue_policy" "tre_forward" {
  queue_url = aws_sqs_queue.tre_forward.id
  policy    = data.aws_iam_policy_document.tre_forward_queue.json
}

resource "aws_sqs_queue" "tre_forward_deadletter" {
  name                    = "${var.env}-${var.prefix}-forward-deadletter"
  sqs_managed_sse_enabled = true
}

resource "aws_lambda_event_source_mapping" "tre_forward_dlq" {
  batch_size                         = 1
  function_name                      = aws_lambda_function.tre_dlq_slack_alerts.function_name
  event_source_arn                   = aws_sqs_queue.tre_forward_deadletter.arn
  maximum_batching_window_in_seconds = 0
}

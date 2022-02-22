resource "aws_sqs_queue" "tdr_message_queue" {
  name = "${var.env}-tdr-message"
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.tdr_message_deadletter_queue.arn}"
    maxReceiveCount     = 5
  })
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue_policy" "name" {
  queue_url = aws_sqs_queue.tdr_message_queue.id
  policy = data.aws_iam_policy_document.tdr_sqs_policy.json
}

resource "aws_sqs_queue" "tdr_message_deadletter_queue" {
  name = "${var.env}-tdr-message-deadletter-queue"
  sqs_managed_sse_enabled = true
}
resource "aws_sqs_queue" "tdr_message_queue" {
  name = "${var.env}-te-tdr-in"
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.tdr_message_deadletter_queue.arn}"
    maxReceiveCount     = 5
  })
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue_policy" "name" {
  queue_url = aws_sqs_queue.tdr_message_queue.id
  policy    = data.aws_iam_policy_document.tdr_sqs_policy.json
}

resource "aws_sqs_queue" "tdr_message_deadletter_queue" {
  name                    = "${var.env}-te-tdr-in-deadletter-queue"
  sqs_managed_sse_enabled = true
}

output "tdr_sqs_queue_arn" {
  value       = aws_sqs_queue.tdr_message_queue.arn
  description = "The ARN of the TDR Input SQS queue"
}

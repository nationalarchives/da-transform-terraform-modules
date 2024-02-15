resource "aws_sqs_queue" "tdr_message_queue" {
  name = "${var.env}-${var.prefix}-tdr-in"
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.tdr_message_deadletter_queue.arn}"
    maxReceiveCount     = 5
  })
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue" "tdr_message_deadletter_queue" {
  name                    = "${var.env}-${var.prefix}-tdr-in-deadletter-queue"
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue" "editorial_message_queue" {
  name = "${var.env}-${var.prefix}-editorial-retry"
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.editorial_retry_deadletter_queue.arn}"
    maxReceiveCount     = 5
  })
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue" "editorial_retry_deadletter_queue" {
  name                    = "${var.env}-${var.prefix}-editorial-retry-deadletter-queue"
  sqs_managed_sse_enabled = true
}


output "tdr_sqs_queue_arn" {
  value       = aws_sqs_queue.tdr_message_queue.arn
  description = "The ARN of the TDR Input SQS queue"
}

output "editorial_sqs_queue_arn" {
  value = aws_sqs_queue.editorial_message_queue.arn
}

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

resource "aws_sqs_queue" "editorial_message_queue" {
  name = "${var.env}-te-editorial-retry"
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.editorial_retry_deadlette_queue.arn}"
    maxReceiveCount     = 5
  })
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue_policy" "editorial_message_queue_policy" {
  queue_url = aws_sqs_queue.editorial_message_queue.id
  policy    = data.aws_iam_policy_document.editorial_sqs_policy.json
}

resource "aws_sqs_queue" "editorial_retry_deadletter_queue" {
  name                    = "${var.env}-te-editorial-retry-deadlette-queue"
  sqs_managed_sse_enabled = true
}


output "tdr_sqs_queue_arn" {
  value       = aws_sqs_queue.tdr_message_queue.arn
  description = "The ARN of the TDR Input SQS queue"
}

output "editorial_sqs_queue_arn" {
  value = aws_sqs_queue.editorial_message_queue.arn
}

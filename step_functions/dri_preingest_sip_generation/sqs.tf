resource "aws_sqs_queue" "tre_dpsg_in" {
  name = "${var.env}-${var.prefix}-dpsg-in"
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.tre_dpsg_in_deadletter.arn}"
    maxReceiveCount     = 5
  })
  sqs_managed_sse_enabled = true 
}

resource "aws_sqs_queue_policy" "tre_dpsg_in" {
  queue_url = aws_sqs_queue.tre_dpsg_in.arn
  policy = data.aws_iam_policy_document.tre_dpsg_in_queue.json
}

resource "aws_sqs_queue" "tre_dpsg_in_deadletter" {
  name = "${var.env}-${var.prefix}-dpsg-in-deadletter"
  sqs_managed_sse_enabled = true
}

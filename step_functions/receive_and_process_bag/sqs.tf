resource "aws_sqs_queue" "tre_rapb_in" {
  name = "${var.env}-${var.prefix}-rapb-in"
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.tre_rapb_in_deadletter.arn}"
    maxReceiveCount     = 5
  })
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue_policy" "name" {
  queue_url = aws_sqs_queue.tre_rapb_in.id
  policy    = data.aws_iam_policy_document.tre_rapb_queue_in.json
}

resource "aws_sqs_queue" "tre_rapb_in_deadletter" {
  name                    = "${var.env}-${var.prefix}-rapb-in-deadletter"
  sqs_managed_sse_enabled = true
}

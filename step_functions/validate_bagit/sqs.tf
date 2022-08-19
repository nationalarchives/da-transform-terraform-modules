resource "aws_sqs_queue" "tre_vb_in" {
  name = "${var.env}-${var.prefix}-vb-in"
  redrive_policy = jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.tre_vb_in_deadletter.arn}"
    maxReceiveCount     = 5
  })
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue_policy" "tre_vb_in" {
  queue_url = aws_sqs_queue.tre_vb_in.id
  policy    = data.aws_iam_policy_document.tre_vb_queue_in.json
}

resource "aws_sqs_queue" "tre_vb_in_deadletter" {
  name                    = "${var.env}-${var.prefix}-vb-in-deadletter"
  sqs_managed_sse_enabled = true
}

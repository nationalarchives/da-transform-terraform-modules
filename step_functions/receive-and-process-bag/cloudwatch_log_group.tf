resource "aws_cloudwatch_log_group" "receive_and_process_bag" {
  name = "${var.env}-${var.prefix}-receive-and-process-bag-logs"
}

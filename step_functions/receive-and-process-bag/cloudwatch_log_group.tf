resource "aws_cloudwatch_log_group" "tdr_state_machine_logs" {
  name = "${var.env}-${var.prefix}-state-machine-logs"
}
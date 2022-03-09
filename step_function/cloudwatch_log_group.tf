resource "aws_cloudwatch_log_group" "tdr_state_machine_logs" {
  name = "${var.env}-tdr-state-machine-logs"
}
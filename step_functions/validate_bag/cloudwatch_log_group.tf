resource "aws_cloudwatch_log_group" "validate_bag" {
  name = "${local.step_function_name}-logs"
}

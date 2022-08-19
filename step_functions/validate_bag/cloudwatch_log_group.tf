resource "aws_cloudwatch_log_group" "validate_bagit" {
  name = "${local.step_function_name}-logs"
}

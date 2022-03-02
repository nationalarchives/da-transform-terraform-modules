resource "aws_sfn_state_machine" "tdr_state_machine" {
  name = "${var.env}-retrive-bagit-machine"
  role_arn = aws_iam_role.tdr_state_machine_role.arn
  definition = file("${path.module}/templates/step-function-definition.json")
  logging_configuration {
     log_destination = "${aws_cloudwatch_log_group.tdr_state_machine_logs.arn}:*"
    include_execution_data = true
    level = "ALL"
  }

  tracing_configuration {
    enabled = true
  }
}

output "sfn_state_machine_arn" {
    value               = aws_sfn_state_machine.tdr_state_machine.arn
    description         = "The ARN of the State Machine"
}

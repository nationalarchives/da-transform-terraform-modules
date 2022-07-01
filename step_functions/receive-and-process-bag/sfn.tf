resource "aws_sfn_state_machine" "receive_and_process_bag" {
  name     = "${var.env}-${var.prefix}-receive-and-process-bag"
  role_arn = aws_iam_role.receive_and_process_bag.arn
  definition = templatefile("${path.module}/templates/step-function-definition.json.tftpl", {
      arn_lambda_rapb_bagit_checksum_validation = aws_lambda_function.rapb_bagit_checksum_validation.arn
      arn_lambda_rapb_files_checksum_validation = aws_lambda_function.rapb_files_checksum_validation.arn
  })
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.tdr_state_machine_logs.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tracing_configuration {
    enabled = true
  }
}

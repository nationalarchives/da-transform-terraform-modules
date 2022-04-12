resource "aws_sfn_state_machine" "tdr_state_machine" {
  name     = "${var.env}-${var.prefix}-state-machine"
  role_arn = aws_iam_role.tdr_state_machine_role.arn
  definition = templatefile("${path.module}/templates/step-function-definition.json.tftpl", {
    bagit_checksum_lambda  = aws_lambda_function.retrieve_bagit_function.arn
    files_checksum_lambda  = aws_lambda_function.bagit_files_checksum_function.arn
    tdr_sqs_queue_endpoint = var.tdr_sqs_queue_endpoint
    tdr_trigger_queue_arn  = var.tdr_trigger_queue_arn
    editorial_retry_trigger_arn = var.editorial_retry_trigger_arn
    editorial_sns_topic_arn = aws_sns_topic.editorial_sns.arn
    prepare_parser_input = aws_lambda_function.prepare_parser_input.arn
    editorial_integration_lambda = aws_lambda_function.editorial_integration.arn
    run_judgments_parser = aws_lambda_function.judgment_parser_lambda.arn
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

output "sfn_state_machine_arn" {
  value       = aws_sfn_state_machine.tdr_state_machine.arn
  description = "The ARN of the State Machine"
}

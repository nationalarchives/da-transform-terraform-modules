resource "aws_sfn_state_machine" "receive_and_process_bag" {
  name     = "${var.env}-${var.prefix}-receive-and-process-bag"
  role_arn = aws_iam_role.receive_and_process_bag.arn
  definition = templatefile("${path.module}/templates/step-function-definition.json.tftpl", {
      arn_lambda_rapb_bagit_checksum_validation = aws_lambda_function.rapb_bagit_checksum_validation.arn
      arn_lambda_rapb_files_checksum_validation = aws_lambda_function.rapb_files_checksum_validation.arn
      arn_sns_topic_receive_and_process_bag_out = var.common_tre_internal_topic_arn
      url_tdr_sqs_retry = var.tdr_sqs_retry_url
      arn_sns_topic_tre_slack_alerts = var.common_tre_slack_alerts_topic_arn
  })
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.receive_and_process_bag.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tracing_configuration {
    enabled = true
  }
}

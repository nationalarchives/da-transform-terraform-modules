resource "aws_sfn_state_machine" "dri_preingest_sip_generation" {
  name = local.step_function_name
  role_arn = aws_iam_role.dri_preingest_sip_generation.arn
  definition = templatefile("${path.module}/templates/step-function-definition.json.tftpl", {
      arn_lambda_dpsg_bagit_to_dri_sip = aws_lambda_function.bagit_to_dri_sip.arn
      arn_sns_topic_tre_slack_alerts = var.common_tre_slack_alerts_topic_arn
      arn_sns_topic_dpsq_out = var.common_tre_internal_topic_arn
  })
  logging_configuration {
    log_destination = "${aws_cloudwatch_log_group.dri_preingest_sip_generation.arn}:*"
    include_execution_data = true
    level = "ALL"
  }

  tracing_configuration {
    enabled = true
  }
}

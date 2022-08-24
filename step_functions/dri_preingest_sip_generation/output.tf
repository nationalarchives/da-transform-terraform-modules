output "dpsg_in_queue_arn" {
  value = aws_sqs_queue.tre_dpsg_in.arn
  description = "ARN of the TRE-DPSG SQS Queue"
}

output "dri_preingest_sip_generation_lambda_role" {
  value = aws_iam_role.dri_preingest_sip_generation_lambda_role.arn
  description = "ARN of the dpsg Lamda Role"
}

output "dri_preingest_sip_generation_role_arn" {
  value = aws_sfn_state_machine.dri_preingest_sip_generation.role_arn
  description = "ARN of the DRI Preingest SIP Generation Step Function Role"

}

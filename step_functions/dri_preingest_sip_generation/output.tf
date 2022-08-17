output "dpsg_in_queue_arn" {
  value = aws_sqs_queue.tre_dpsg_in.arn
  description = "ARN of the TRE-DPSG SQS Queue"
}

output "dri_preingest_sip_generation_lambda_role" {
  value = aws_iam_role.dri_preingest_sip_generation_lambda_role.arn
  description = "ARN of the dpsg Lamda Role"
}
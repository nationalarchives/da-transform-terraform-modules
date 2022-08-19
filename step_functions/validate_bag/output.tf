output "validate_bag_lambda_invoke_role" {
  value = aws_iam_role.validate_bag_lambda_invoke_role.arn
  description = "ARN of the Validate Bag Step Function Lambda Invoke Role"
}

output "validate_bag_role_arn" {
  value = aws_iam_role.validate_bag.arn
  description = "ARN of the Validate Bag Step Function Role"
}

output "validate_bag_arn" {
  value = aws_sfn_state_machine.validate_bag.arn
  description = "ARN of the Validate Bag step function"
}

output "tre_vb_in_queue_arn" {
  value = aws_sqs_queue.tre_vb_in.arn
  description = "ARN of the tre-vb-in SQS Queue"
}

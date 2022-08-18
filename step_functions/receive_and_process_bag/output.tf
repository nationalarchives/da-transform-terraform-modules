output "receive_process_bag_lambda_invoke_role" {
  value = aws_iam_role.receive_and_process_bag_lambda_invoke_role.arn
  description = "ARN of the Receive and Process Step Function Lambda Invoke Role"
}

output "receive_and_process_bag_role_arn" {
  value = aws_iam_role.receive_and_process_bag.arn
  description = "ARN of the receive and process bag Step Function Role"
}

output "receive_and_process_bag_arn" {
  value = aws_sfn_state_machine.receive_and_process_bag.arn
  description = "ARN of the receive and process bag step function"
}

output "tre_rapb_in_queue_arn" {
  value = aws_sqs_queue.tre_rapb_in.arn
  description = "ARN of the tre-rapb-in SQS Queue"
}

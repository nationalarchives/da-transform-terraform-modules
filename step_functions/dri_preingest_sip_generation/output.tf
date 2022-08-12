output "dpsg_in_queue_arn" {
  value = aws_sqs_queue.tre_dpsg_in.arn
  description = "ARN of the TRE-DPSG SQS Queue"
}

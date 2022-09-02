output "common_tre_slack_alerts_topic_arn" {
  value       = aws_sns_topic.common_tre_slack_alerts.arn
  description = "ARN of the Common TRE Slack Alerts"
}

output "common_tre_data_bucket" {
  value       = aws_s3_bucket.common_tre_data.bucket
  description = "Common TRE Data Bucket"
}

output "common_tre_internal_topic_arn" {
  value       = aws_sns_topic.tre_internal.arn
  description = "Common TRE internal topic arn"
}

output "common_tre_out_topic_arn" {
  value       = aws_sns_topic.tre_out.arn
  description = "Common TRE out topic arn"
}

output "tre_forward_lambda_arn" {
  value       = aws_iam_role.tre_forward_lambda_role.arn
  description = "TRE Forward Lambda Role ARN"
}

output "tre_forward_queue_arn" {
  value = aws_sqs_queue.tre_forward.arn
  description = "TRE Forward SQS Queue ARN"
}
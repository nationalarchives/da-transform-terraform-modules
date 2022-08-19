output "common_tre_slack_alerts_topic_arn" {
  value = aws_sns_topic.common_tre_slack_alerts.arn
  description = "ARN of the Common TRE Slack Alerts"
}

output "common_tre_data_bucket" {
  value = aws_s3_bucket.common_tre_data.bucket
  description = "Common TRE Data Bucket"
}

output "common_tre_internal_topic_arn" {
  value = aws_sns_topic.tre_internal.arn
  description = "Common TRE internal topic arn"
}

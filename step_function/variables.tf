variable "env" {
  description = "Name of the environment to deploy"
  type        = string
}

variable "prefix" {
  description = "Transformation Engine prefix"
  type = string
}

variable "tdr_sqs_queue_endpoint" {
  description = "Endpoint of the TDR SQS Queue for the retry message"
  type        = string
}

variable "tdr_sqs_queue_arn" {
  description = "ARN of the TDR SQS Queue for the retry message"
  type        = string
}

variable "tdr_queue_kms_key" {
  description = "ARN of the KMS Key for TDR SQS Queue "
  type = string
}

variable "tdr_trigger_queue_arn" {
  description = "ARN of the tdr trigger queue"
  type = string
}

variable "editorial_retry_trigger_arn" {
  description = "ARN of the editorial retry trigger queue"
  type = string
}

variable "editorial_sns_sub_arn" {
  description = "ARN of the editorial SNS Subscription role"
  type = string
}

variable "account_id" {
  description = "Account ID where Image for the Lambda function will be"
  type = string
}

variable "tre_version" {
  description = "TRE Step Function version (update if Step Function flow or called Lambda function versions change)"
  type = string
}

variable "image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    tre_bagit_checksum_validation = string
    tre_files_checksum_validation = string
    tre_prepare_parser_input = string
    tre_editorial_integration = string
    tre_run_judgment_parser = string
    tre_slack_alerts = string
  })
}

# Slack

variable "slack_webhook_url" {
  description = "Webhook URL for tre slack alerts"
  type = string
}

variable "slack_channel" {
  description = "Channel name for the tre slack alerts"
  type = string
}

variable "slack_username" {
  description = "Username for tre slack alerts"
  type = string
}

# S3

variable "receive_process_bag_lambda_access_role" {
  description = "Lambda role to access TRE Temp Bucket"
  type = string
}
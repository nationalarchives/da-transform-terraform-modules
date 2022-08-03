variable "env" {
  description = "Name of the environment to deploy"
  type        = string
}

variable "prefix" {
  description = "Transformation Engine prefix"
  type = string
}


variable "account_id" {
  description = "Account ID where Image for the Lambda function will be"
  type = string
}

variable "tre_data_bucket" {
  description = "TRE Data Bucket Name"
  type = string
}

variable "rapb_version" {
  description = "Receive And Process Bag Step Function version (update if Step Function flow or called Lambda function versions change)"
  type = string
  
}

variable "rapb_image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    tre_bagit_checksum_validation = string
    tre_files_checksum_validation = string
    tre_rapb_trigger = string
  })
}

variable "common_tre_slack_alerts_topic_arn" {
  description = "ARN of the Common TRE Slack Alerts SNS Topic"
  type = string
}

variable "common_tre_in_sns_topic_arn" {
  description = "ARN of the Common TRE In SNS Topic"
  type = string
}

variable "tdr_sqs_retry_url" {
  description = "The TDR retry SQS Queue URL"
  type = string
}

variable "tdr_sqs_retry_arn" {
  description = "The TDR retry SQS Queue ARN"
  type = string
}

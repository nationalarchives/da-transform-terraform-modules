variable "env" {
  description = "Name of the environment to deploy"
  type        = string
}

variable "prefix" {
  description = "Transformation Engine prefix"
  type        = string
}


variable "account_id" {
  description = "Account ID where Image for the Lambda function will be"
  type        = string
}

variable "tre_data_bucket" {
  description = "TRE Data Bucket Name"
  type        = string
}

variable "vb_version" {
  description = "Validate BagIt Step Function version (update if Step Function flow or called Lambda function versions change)"
  type        = string

}

variable "vb_image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    tre_sqs_sf_trigger    = string
    tre_vb_validate_bagit = string

    tre_vb_validate_bagit_files = string
  })
}

variable "common_tre_slack_alerts_topic_arn" {
  description = "ARN of the Common TRE Slack Alerts SNS Topic"
  type        = string
}

variable "tdr_sqs_retry_url" {
  description = "The TDR retry SQS Queue URL"
  type        = string
}

variable "tdr_sqs_retry_arn" {
  description = "The TDR retry SQS Queue ARN"
  type        = string
}

variable "common_tre_internal_topic_arn" {
  description = "The TRE internal SNS topic ARN"
  type        = string
}

variable "tre_dlq_alerts_lambda_function_name" {
  description = "TRE DLQ Alerts Lambda Function Name"
  type        = string
}

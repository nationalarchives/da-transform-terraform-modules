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

variable "common_tre_slack_alerts_topic_arn" {
  description = "ARN of the Common TRE Slack Alerts SNS Topic"
  type        = string
}

variable "dpsg_version" {
  description = "DRI Preingest SIP Generation Step Function version (update if Step Function flow or called Lambda function versions change)"
  type        = string

}

variable "dpsg_image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    tre_bagit_to_dri_sip = string
    tre_sqs_sf_trigger   = string
  })
}

variable "common_tre_internal_topic_arn" {
  description = "The TRE out SNS topic ARN"
  type        = string
}

variable "tre_dlq_alerts_lambda_function_name" {
  description = "TRE DLQ Alerts Lambda Function Name"
  type        = string
}

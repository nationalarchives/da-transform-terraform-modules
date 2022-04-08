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

variable "api_endpoint" {
  description = "Endpoint for Parser API Gateway"
  type = string
}

variable "account_id" {
  description = "Account ID where Image for the Lambda function will be"
  type = string
}

variable "image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    te_bagit_checksum_validation = string
    te_files_checksum_validation = string
    te_text_parser_step_function = string
    te_editorial_integration = string
  })
}
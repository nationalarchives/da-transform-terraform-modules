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

variable "tre_temp_bucket" {
  description = "TRE Temp Bucket Name"
  type = string
}

variable "rapb_version" {
  
}

variable "rapb_image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    tre_bagit_checksum_validation = string
    tre_files_checksum_validation = string
  })
}

variable "common_tre_slack_alerts_topic_arn" {
  description = "ARN of the Common TRE SLAck Alerts SNS Topic"
  type = string
}
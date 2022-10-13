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

variable "common_version" {
  description = "(Updates if Common TRE Lambda function versions change)"
  type        = string
}
variable "common_image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    tre_slack_alerts     = string
    tre_forward          = string
    tre_dlq_slack_alerts = string
  })
}

variable "tre_slack_alerts_publishers" {
  description = "Roles that have permission to publish messages to tre-slack-alerts topic"
  type        = list(string)
}

variable "tre_data_bucket_write_access" {
  description = "Roles that have write access to tre-data-bucket"
  type        = list(string)
}

variable "slack_webhook_url" {
  description = "Webhook URL for tre slack alerts"
  type        = string
}

variable "slack_channel" {
  description = "Channel name for the tre slack alerts"
  type        = string
}

variable "slack_username" {
  description = "Username for tre slack alerts"
  type        = string
}

variable "tre_in_publishers" {
  description = "Roles that have permission to publish messages to tre-in topic"
  type        = list(string)
}

variable "tre_internal_publishers" {
  description = "Roles that have permission to publish messages to tre-internal topic"
  type        = list(string)
}

variable "tre_out_publishers" {
  description = "Roles that have permission to publish messages to tre-out topic"
  type        = list(string)
}

variable "tre_in_subscriptions" {
  description = "List tre-in topic subscriptions"
  type = list(object({
    name     = string
    endpoint = string
    protocol = string
  }))
}

variable "tre_internal_subscriptions" {
  description = "List tre-internal topic subscriptions"
  type = list(object({
    name          = string
    endpoint      = string
    filter_policy = any
    protocol      = string
  }))
}

variable "tre_out_subscriptions" {
  description = "List tre-out topic subscriptions"
  type = list(object({
    name     = string
    endpoint = string
    protocol = string
  }))
}

variable "tre_out_subscribers" {
  type = list(object({
    sid          = string
    subscriber   = list(string)
    endpoint_arn = list(string)
  }))
}

variable "tdr_tre_in_publisher" {
  description = "ARN of the Role which is used by TDR to publish message to TRE In"
  type        = list(string)
}

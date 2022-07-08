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

variable "image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    tre_slack_alerts = string
  })
}

variable "sfn_arns" {
  description = "ARNs of the State Machines"
  type = list(string)
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

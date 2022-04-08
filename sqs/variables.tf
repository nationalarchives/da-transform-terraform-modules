variable "env" {
  description = "Name of the environment where the resource will be created"
}

variable "prefix" {
  description = "Transformation Engine prefix"
  type = string
}

variable "tdr_role_arn" {
  description = "role ARN for TDR to submit to SQS queues"
  type        = string
}

variable "editorial_role_arn" {
  description = "role ARN for editorial retry message"
  type        = string
}

variable "sfn_arn" {
  description = "role ARN for the stepfunction"
}

variable "account_id" {
  description = "Account ID where Image for the Lambda function will be"
  type = string
}

variable "image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    te_step_function_trigger = string
  })
}


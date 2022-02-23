variable "env" {
  description = "Name of the environment where the resource will be created"
}

variable "tdr_role_arn" {
  description = "role ARN for TDR to submit to SQS queues"
  type = string
}

variable "sfn_arn" {
}
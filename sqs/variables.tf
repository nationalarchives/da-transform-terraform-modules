variable "env" {
  # default = "test"
  description = "Name of the environment where the resource will be created"
}

variable "tdr_role_arn" {
  # default = "079564067364"
  description = "role ARN for TDR to submit to SQS queues"
  type = string
}

variable "sfn_arn" {
  # default = "arn:aws:states:eu-west-2:079564067364:stateMachine:test-retrive-bagit-machine"
}
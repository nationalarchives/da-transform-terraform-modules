variable "env" {
  description = "Name of the environment to deploy"
  type = string
}

variable "tdr_sqs_queue_endpoint" {
  description = "Endpoint of the TDR SQS Queue for the retry message"
  type = string
}

# variable "tdr_sqs_queue_arn" {
#   description = "ARN of the TDR SQS Queue for the retry message"
#   type = string
# }
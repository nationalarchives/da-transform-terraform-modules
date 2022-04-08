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
    te_text_parser = string
  })
}
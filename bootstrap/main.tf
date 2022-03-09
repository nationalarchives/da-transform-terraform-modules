variable "aws_region" {
  description = "Region in which to create resources"
  type        = string
  default     = "eu-west-2"
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "da-transform-terraform-state"

  # enable this to store history of state files
  # there are cost implications
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "da-transform-terraform-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}

# Sample terraform backend configuration to use this setup
# terraform {
#     backend "s3" {
#         bucket          = "da-transform-terraform-statr"
#         key             = "global/s3/terraform.tfstate"
#         region          = "eu-west-2"
#         dynamodb_table  = "da-transform-terraform-state"
#         encrypt         = true
#     }
# }

terraform {
  backend "s3" {
    region         = "eu-west-2"
    bucket         = "da-transform-terratest-terraform-state"
    key            = "environments/test/terraform.tfstate"
    dynamodb_table = "da-transform-terratest-terraform-state"
    encrypt        = true

  }
}


terraform {
  backend "s3" {
    region         = "eu-west-2"
    bucket         = "da-transform-terratest-terraform-state"
    key            = "environments/test/terraform.tfstate"
    dynamodb_table = "da-transform-terratest-terraform-state"
    encrypt        = true
    role_arn       = "arn:aws:iam::454286877087:role/IAM_Admin_Role"

  }
}


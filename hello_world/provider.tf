provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::454286877087:role/terraform"
  }
}
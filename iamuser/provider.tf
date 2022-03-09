provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::454286877087:role/IAM_Admin_Role"
  }
}

provider "aws" {
  alias  = "users"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::528553943715:role/IAM_Admin_Role"
  }
}

provider "aws" {
  alias  = "mgmt"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::454286877087:role/IAM_Admin_Role"
  }
}

terraform {
  backend "s3" {
    role_arn       = "arn:aws:iam::454286877087:role/IAM_Admin_Role"
    bucket         = "da-transform-terraform-state"
    key            = "module/iamuser/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "da-transform-terraform-state"
    encrypt        = true
  }
}

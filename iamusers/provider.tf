provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::454286877087:role/IAM_Admin_Role"
  }
}

provider "aws" {
  alias = "users"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::528553943715:role/IAM_Admin_Role"
  }
}

provider "aws" {
  alias = "mgmt"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::454286877087:role/IAM_Admin_Role"
  }
}

terraform {
    backend "s3" {
    }
}

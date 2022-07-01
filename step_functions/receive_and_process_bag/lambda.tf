resource "aws_lambda_function" "rapb_bagit_checksum_validation" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-bagit-checksum-validation:${var.rapb_image_versions.tre_bagit_checksum_validation}"
  package_type  = "Image"
  function_name = "${var.env}-${var.prefix}-rapb-bagit-checksum-validation"
  role          = aws_iam_role.receive_and_process_bag_lambda_invoke_role.name
  timeout       = 30

  environment {
    variables = {
      "S3_TEMPORARY_BUCKET" = var.tre_temp_bucket
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}

resource "aws_lambda_function" "rapb_files_checksum_validation" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-files-checksum-validation:${var.rapb_image_versions.tre_files_checksum_validation}"
  package_type  = "Image"
  function_name = "${var.env}-${var.prefix}-rapb-files-checksum-validation"
  role          = aws_iam_role.receive_and_process_bag_lambda_invoke_role.name
  timeout       = 30

  environment {
    variables = {
      "S3_TEMPORARY_BUCKET" = var.tre_temp_bucket
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}

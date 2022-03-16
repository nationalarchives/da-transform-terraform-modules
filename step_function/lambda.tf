resource "aws_lambda_function" "retrieve_bagit_function" {
  image_uri     = "882876621099.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-bagit-checksum-validation:0.0.6"
  package_type  = "Image"
  function_name = "${var.env}-te-bagit-checksum-validation"
  role          = aws_iam_role.retrieve_bagit_lambda_role.arn
  timeout       = 30

  environment {
    variables = {
      "S3_TEMPORARY_BUCKET" = aws_s3_bucket.tdr_bagit_out.bucket
    }
  }
}

resource "aws_lambda_function" "bagit_files_checksum_function" {
  image_uri     = "882876621099.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-files-checksum-validation:0.0.4"
  package_type  = "Image"
  function_name = "${var.env}-te-files-checksum-validation"
  role          = aws_iam_role.retrieve_bagit_lambda_role.arn
  timeout       = 30

  environment {
    variables = {
      "S3_TEMPORARY_BUCKET" = aws_s3_bucket.tdr_bagit_out.bucket
    }
  }
}

resource "aws_lambda_function" "run_judgments_parser" {
  image_uri = "882876621099.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-text-parser-step-function:0.0.8"
  package_type = "Image"
  function_name = "${var.env}-te-run-judgments-parser"
  role = aws_iam_role.retrieve_bagit_lambda_role.arn
  timeout = 30
}

resource "aws_lambda_function" "editorial_integration" {
  image_uri = "882876621099.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-editorial-integration:0.0.6"
  package_type = "Image"
  function_name = "${var.env}-te-editorial-integration"
  role = aws_iam_role.retrieve_bagit_lambda_role.arn
  timeout = 30
  environment {
    variables = {
      "TE_VERSION_JSON" = {"int-te-version": "0.0.0", "text-parser-version": "v0.0", "lambda-functions-version": [ { "int-te-bagit-checksum-validation": "0.0.0" }, { "int-te-files-checksum-validation": "0.0.0" }, { "int-text-parser-version": "v0.0" } ]}
      "TE_PRESIGNED_URL_EXPIRY" = 300
    }
  }
}
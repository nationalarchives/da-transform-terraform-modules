resource "aws_lambda_function" "retrieve_bagit_function" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-bagit-checksum-validation:0.0.6"
  package_type  = "Image"
  function_name = "${var.env}-${var.prefix}-bagit-checksum-validation"
  role          = aws_iam_role.retrieve_bagit_lambda_role.arn
  timeout       = 30

  environment {
    variables = {
      "S3_TEMPORARY_BUCKET" = aws_s3_bucket.tdr_bagit_out.bucket
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}

resource "aws_lambda_function" "bagit_files_checksum_function" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-files-checksum-validation:0.0.6"
  package_type  = "Image"
  function_name = "${var.env}-${var.prefix}-files-checksum-validation"
  role          = aws_iam_role.retrieve_bagit_lambda_role.arn
  timeout       = 30

  environment {
    variables = {
      "S3_TEMPORARY_BUCKET" = aws_s3_bucket.tdr_bagit_out.bucket
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}

resource "aws_lambda_function" "run_judgments_parser" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-text-parser-step-function:0.0.10"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-run-judgments-parser"
  role = aws_iam_role.retrieve_bagit_lambda_role.arn
  timeout = 30
  environment {
    variables = {
      "S3_PARSER_BUCKET" = aws_s3_bucket.editorial_judgment_out.bucket
      "API_ENDPOINT" = var.api_endpoint
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}

resource "aws_lambda_function" "editorial_integration" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-editorial-integration:0.0.9"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-editorial-integration"
  role = aws_iam_role.retrieve_bagit_lambda_role.arn
  timeout = 30
  environment {
    variables = {
      "TE_VERSION_JSON" = jsonencode({"int-${var.prefix}-version": "0.0.0", "text-parser-version": "v0.0", "lambda-functions-version": [ { "int-${var.prefix}-bagit-checksum-validation": "0.0.0" }, { "int-${var.prefix}-files-checksum-validation": "0.0.0" }, { "int-text-parser-version": "v0.0" } ]})
      "TE_PRESIGNED_URL_EXPIRY" = 60
      "S3_BUCKET" = aws_s3_bucket.editorial_judgment_out.bucket
      "S3_OBJECT_ROOT" = "parsed/"
      "S3_FILE_PARSER_META"="te-meta.json"
      "S3_FILE_BAGIT_INFO"="bagit-info.txt"
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}
resource "aws_lambda_function" "retrieve_bagit_function" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-bagit-checksum-validation:${var.image_versions.tre_bagit_checksum_validation}"
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
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-files-checksum-validation:${var.image_versions.tre_files_checksum_validation}"
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

resource "aws_lambda_function" "prepare_parser_input" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-prepare-parser-input:${var.image_versions.tre_prepare_parser_input}"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-prepare-parser-input"
  role = aws_iam_role.retrieve_bagit_lambda_role.arn
  timeout = 30
  environment {
    variables = {
      "S3_PARSER_BUCKET" = aws_s3_bucket.editorial_judgment_out.bucket
      "TE_PRESIGNED_URL_EXPIRY" = 300
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}

# Run Parser Function

resource "aws_lambda_function" "judgment_parser_lambda" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-run-judgment-parser:${var.image_versions.tre_run_judgment_parser}"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-run-judgment-parser"
  role = aws_iam_role.retrieve_bagit_lambda_role.arn
  memory_size = 1536
  timeout = 900

  tags = {
    ApplicationType = ".NET"
  }
}

resource "aws_lambda_function" "editorial_integration" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-editorial-integration:${var.image_versions.tre_editorial_integration}"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-editorial-integration"
  role = aws_iam_role.retrieve_bagit_lambda_role.arn
  memory_size = 512
  timeout = 900
  environment {
    variables = {
      "TRE_VERSION_JSON" = jsonencode(
        {
          "${var.env}-${var.prefix}-version": "${var.image_versions.tre_step_function_version}",
          "lambda-functions-version": [
            {"${var.env}-${var.prefix}-bagit-checksum-validation": "${var.image_versions.tre_bagit_checksum_validation}"},
            {"${var.env}-${var.prefix}-files-checksum-validation": "${var.image_versions.tre_files_checksum_validation}"},
            {"${var.env}-${var.prefix}-prepare-parser-input": "${var.image_versions.tre_prepare_parser_input}"},
            {"${var.env}-${var.prefix}-editorial-integration": "${var.image_versions.tre_editorial_integration}"},
            {"${var.env}-${var.prefix}-run-judgments-parser": "${var.image_versions.tre_run_judgment_parser}"},
            {"${var.env}-${var.prefix}-slack-alerts": "${var.image_versions.tre_slack_alerts}"}
          ]
        }
      )
      "TRE_PRESIGNED_URL_EXPIRY" = 60
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

# SNS Slack Alerts

resource "aws_lambda_function" "tre_slack_alerts_function" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-slack-alerts:${var.image_versions.tre_slack_alerts}"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-slack-alerts"
  role = aws_iam_role.tre_slack_alerts_lambda_role.arn
  timeout = 30
  environment {
    variables = {
      "SLACK_WEBHOOK_URL" = var.slack_webhook_url
      "ENV" = var.env
      "SLACK_CHANNEL" = var.slack_channel
      "SLACK_USERNAME" = var.slack_username
    }
  }

  tags = {
    "ApplicationType" = "Python"
  }
}

resource "aws_lambda_permission" "tre_slakc_alerts_sns_trigger_permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tre_slack_alerts_function.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.tre_slack_alerts.arn
}
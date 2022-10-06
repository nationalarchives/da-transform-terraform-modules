resource "aws_lambda_function" "vb_bagit_checksum_validation" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-vb-validate-bagit:${var.vb_image_versions.tre_vb_validate_bagit}"
  package_type  = "Image"
  function_name = local.lambda_name_bagit_validation
  role          = aws_iam_role.validate_bagit_lambda_invoke_role.arn
  timeout       = 30

  environment {
    variables = {
      "TRE_S3_BUCKET"            = var.tre_data_bucket
      "TRE_SF_VERSION"           = var.vb_version
      "TRE_LAMBDA_VERSIONS"      = jsonencode(var.vb_image_versions)
      "TRE_SYSTEM_NAME"          = upper(var.prefix)
      "TRE_PROCESS_NAME"         = local.step_function_name
      "TRE_STEP_FUNCTION_NAME"   = local.step_function_name
      "TRE_LAMBDA_FUNCTION_NAME" = local.lambda_name_bagit_validation
      "TRE_ENVIRONMENT"          = var.env
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}

resource "aws_lambda_function" "vb_files_checksum_validation" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-vb-validate-bagit-files:${var.vb_image_versions.tre_vb_validate_bagit_files}"
  package_type  = "Image"
  function_name = local.lambda_name_files_validation
  role          = aws_iam_role.validate_bagit_lambda_invoke_role.arn
  timeout       = 30

  environment {
    variables = {
      "TRE_S3_BUCKET"            = var.tre_data_bucket
      "TRE_SF_VERSION"           = var.vb_version
      "TRE_LAMBDA_VERSIONS"      = jsonencode(var.vb_image_versions)
      "TRE_SYSTEM_NAME"          = upper(var.prefix)
      "TRE_PROCESS_NAME"         = local.step_function_name
      "TRE_STEP_FUNCTION_NAME"   = local.step_function_name
      "TRE_LAMBDA_FUNCTION_NAME" = local.lambda_name_files_validation
      "TRE_ENVIRONMENT"          = var.env
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}


# vb_step_function_trigger
resource "aws_lambda_function" "vb_trigger" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-sqs-sf-trigger:${var.vb_image_versions.tre_sqs_sf_trigger}"
  package_type  = "Image"
  function_name = local.lambda_name_trigger
  role          = aws_iam_role.vb_trigger_lambda.arn
  timeout       = 30

  environment {
    variables = {
      "TRE_STATE_MACHINE_ARN"    = aws_sfn_state_machine.validate_bagit.arn
      "TRE_CONSIGNMENT_KEY_PATH" = "parameters.bagit-available.reference"
    }
  }
}

resource "aws_lambda_event_source_mapping" "vb_in_sqs" {
  batch_size                         = 1
  function_name                      = aws_lambda_function.vb_trigger.function_name
  event_source_arn                   = aws_sqs_queue.tre_vb_in.arn
  maximum_batching_window_in_seconds = 0
}

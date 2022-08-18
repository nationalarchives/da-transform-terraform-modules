resource "aws_lambda_function" "rapb_bagit_checksum_validation" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-validate-bagit:${var.rapb_image_versions.tre_validate_bagit}"
  package_type  = "Image"
  function_name = local.lambda_name_bagit_validation
  role          = aws_iam_role.receive_and_process_bag_lambda_invoke_role.arn
  timeout       = 30

  environment {
    variables = {
      "TRE_S3_BUCKET" = var.tre_data_bucket
      "TRE_SF_VERSION" = var.rapb_version
      "TRE_LAMBDA_VERSIONS" = jsonencode(var.rapb_image_versions)
      "TRE_SYSTEM_NAME" = upper(var.prefix)
      "TRE_PROCESS_NAME" = local.step_function_name
      "TRE_STEP_FUNCTION_NAME" = local.step_function_name
      "TRE_LAMBDA_FUNCTION_NAME" = local.lambda_name_bagit_validation
      "TRE_ENVIRONMENT" = var.env
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}

resource "aws_lambda_function" "rapb_files_checksum_validation" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-validate-bagit-files:${var.rapb_image_versions.tre_validate_bagit_files}"
  package_type  = "Image"
  function_name = local.lambda_name_files_validation
  role          = aws_iam_role.receive_and_process_bag_lambda_invoke_role.arn
  timeout       = 30

  environment {
    variables = {
      "TRE_S3_BUCKET" = var.tre_data_bucket
      "TRE_SF_VERSION" = var.rapb_version
      "TRE_LAMBDA_VERSIONS" = jsonencode(var.rapb_image_versions)
      "TRE_SYSTEM_NAME" = upper(var.prefix)
      "TRE_PROCESS_NAME" = local.step_function_name
      "TRE_STEP_FUNCTION_NAME" = local.step_function_name
      "TRE_LAMBDA_FUNCTION_NAME" = local.lambda_name_files_validation
      "TRE_ENVIRONMENT" = var.env
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}


# rapb_step_function_trigger

resource "aws_lambda_function" "rapb_trigger" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-rapb-trigger:${var.rapb_image_versions.tre_rapb_trigger}"
  package_type = "Image"
  function_name = local.lambda_name_trigger
  role = aws_iam_role.rapb_trigger_lambda.arn
  timeout = 30

  environment {
    variables = {
      "TRE_STATE_MACHINE_ARN" = aws_sfn_state_machine.receive_and_process_bag.arn
      "TRE_CONSIGNMENT_KEY_PATH" = "parameters.consignment-export.reference"
      "TRE_RETRY_KEY_PATH" = "parameters.consignment-export.number-of-retries"
    }
  }
}

resource "aws_lambda_event_source_mapping" "rapb_in_sqs" {
  batch_size                         = 3
  function_name                      = aws_lambda_function.rapb_trigger.function_name
  event_source_arn                   = aws_sqs_queue.tre_rapb_in.arn
  maximum_batching_window_in_seconds = 0
}

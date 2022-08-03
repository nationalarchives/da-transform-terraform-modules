resource "aws_lambda_function" "rapb_bagit_checksum_validation" {
  image_uri     = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-bagit-checksum-validation:${var.rapb_image_versions.tre_bagit_checksum_validation}"
  package_type  = "Image"
  function_name = "${var.env}-${var.prefix}-rapb-bagit-checksum-validation"
  role          = aws_iam_role.receive_and_process_bag_lambda_invoke_role.arn
  timeout       = 30

  environment {
    variables = {
      "S3_TEMPORARY_BUCKET" = var.tre_data_bucket
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
  role          = aws_iam_role.receive_and_process_bag_lambda_invoke_role.arn
  timeout       = 30

  environment {
    variables = {
      "S3_TEMPORARY_BUCKET" = var.tre_data_bucket
    }
  }

  tags = {
    ApplicationType = "Python"
  }
}


# rapb_step_function_trigger

resource "aws_lambda_function" "rapb_trigger" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-step-function-trigger:latest"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-rapb-trigger"
  role = aws_iam_role.rapb_trigger_lambda.arn
  timeout = 30

  environment {
    variables = {
      "RAPB_ARN" = aws_sfn_state_machine.receive_and_process_bag.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "rapb_in_sqs" {
  batch_size                         = 3
  function_name                      = aws_lambda_function.rapb_trigger.function_name
  event_source_arn                   = aws_sqs_queue.tre_rapb_in.arn
  maximum_batching_window_in_seconds = 0
}

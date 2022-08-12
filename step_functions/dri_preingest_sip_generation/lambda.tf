resource "aws_lambda_function" "bagit_to_dri_sip" {
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-bagit-to-dri-sip:${var.dpsg_image_versions.tre_bagit_to_dri_sip}"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-bagit-to-dri-sip"
  role = aws_iam_role.dri_preingest_sip_generation_lambda_role.arn
  timeout = 300

  environment {
    variables = {
      "S3-DRI-OUT-BUCKET" = aws_s3_bucket.dpsg_out.bucket
    }
  }
}

# dpsg_step_function_trigger

resource "aws_lambda_function" "dpsg_trigger" {
  // IAMGE URI REPO TBC
  image_uri = "${var.account_id}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tre-rapb-trigger:${var.dpsg_image_versions.tre_rapb_trigger}"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-dpsg-trigger"
  role = aws_iam_role.dpsg_trigger.arn
  timeout = 30

  environment {
    variables = {
      "DPSG_ARN" = aws_sfn_state_machine.dri_preingest_sip_generation.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "dpsg_in_sqs" {
  batch_size = 3
  function_name = aws_lambda_function.dpsg_trigger.function_name
  event_source_arn = aws_sqs_queue.tre_dpsg_in.arn
  maximum_batching_window_in_seconds = 0
}
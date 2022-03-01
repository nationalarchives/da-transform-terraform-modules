resource "aws_lambda_function" "retrieve_bagit_function" {
  image_uri = "882876621099.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/tdr-to-temporary-s3:latest"
  package_type = "Image"
  function_name = "${var.env}-retrive-tdr-bagit"
  role = aws_iam_role.retrieve_bagit_lambda_role.arn
  handler = "tdr_to_temporary_s3.handler"
  runtime = "python3.8"
  timeout = 30

  environment {
    variables = {
      "S3_TEMPORARY_BUCKET" = aws_s3_bucket.tdr_bagit_out.bucket
    }
  }
}
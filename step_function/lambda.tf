data "archive_file" "retrieve_bagit_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/retrieve_bagit.py"
  output_path = "${path.module}/retrieve_bagit.zip"
}

resource "aws_lambda_function" "retrieve_bagit_function" {
  filename = data.archive_file.retrieve_bagit_lambda_zip.output_path
  function_name = "${var.env}-retrive-tdr-bagit"
  role = aws_iam_role.retrieve_bagit_lambda_role.arn
  handler = "retrieve_bagit.lambda_handler"
  source_code_hash = data.archive_file.retrieve_bagit_lambda_zip.output_base64sha256
  runtime = "python3.8"
  timeout = 30
}
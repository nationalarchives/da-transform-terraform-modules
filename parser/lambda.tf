resource "aws_lambda_function" "judgment_parser_lambda" {
  image_uri = "882876621099.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions/te-text-parser:v0.2"
  package_type = "Image"
  function_name = "${var.env}-${var.prefix}-judgment-parser"
  role = aws_iam_role.judgment_parser_lambda_role.arn
  timeout = 30

  tags = {
    ApplicationType = ".NET"
  }
}

resource "aws_lambda_permission" "api_invocation" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.judgment_parser_lambda.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.judgment_parser_api.execution_arn}/*/*/${aws_lambda_function.judgment_parser_lambda.function_name}"
}

output "lambda_name" {
  value = aws_lambda_function.judgment_parser_lambda.function_name
}
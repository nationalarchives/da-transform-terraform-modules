resource "aws_apigatewayv2_api" "judgment_parser_api" {
  name = "${var.env}-te-judgment-parser-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "judgment_parser_api" {
  api_id = aws_apigatewayv2_api.judgment_parser_api.id
  name = "${var.env}-te-judgment-parser-lambda"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.judgment_parser_api_logs.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "judgment_parser_api" {
  api_id = aws_apigatewayv2_api.judgment_parser_api.id
  integration_uri = aws_lambda_function.judgment_parser_lambda.invoke_arn
  integration_method = "ANY"
  integration_type = "AWS"
}

resource "aws_apigatewayv2_route" "judgment_parser_api" {
  api_id = aws_lambda_function.judgment_parser_lambda.id
  route_key = "$default"
  target = "integration/${aws_apigatewayv2_integration.judgment_parser_api.id}"
}

resource "aws_cloudwatch_log_group" "judgment_parser_api_logs" {
  name = "${var.env}-te-judgment-parser-api-logs"
}

output "parser_api_endpoint" {
  value = aws_apigatewayv2_stage.judgment_parser_api.invoke_url
}
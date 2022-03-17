resource "aws_iam_role" "judgment_parser_lambda_role" {
  name = "${var.env}-te-judgment-parser-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.judgment_parser_lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "judgment_parser_lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "judgment_parser_lambda_role_policy" {
  role       = aws_iam_role.judgment_parser_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}
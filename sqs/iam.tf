# Lambda roles and policies
resource "aws_iam_role" "tdr_message_lambda_role" {
  name               = "${var.env}-${var.prefix}-step-function-trigger-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  inline_policy {
    name   = "${var.env}-${var.prefix}-step-function-execution"
    policy = data.aws_iam_policy_document.step_function_execution.json
  }
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role       = aws_iam_role.tdr_message_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

data "aws_iam_policy_document" "step_function_execution" {
  statement {
    actions   = ["states:StartExecution"]
    effect    = "Allow"
    resources = [var.sfn_arn]
  }
}
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


# SQS Queue policy document

data "aws_iam_policy_document" "tdr_sqs_policy" {
  statement {
    actions = ["sqs:SendMessage"]
    effect  = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.tdr_role_arn
      ]
    }
    resources = [
      aws_sqs_queue.tdr_message_queue.arn
    ]
  }
}

data "aws_iam_policy_document" "editorial_sqs_policy" {
  statement {
    actions = ["sqs:SendMessage"]
    effect  = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.editorial_role_arn
      ]
    }
    resources = [
      aws_sqs_queue.editorial_message_queue.arn
    ]
  }
}


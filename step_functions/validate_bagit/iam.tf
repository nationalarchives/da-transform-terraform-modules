# Step Function Roles and Policies

resource "aws_iam_role" "validate_bagit" {
  name               = "${local.step_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.validate_bagit_assume_role_policy.json
  inline_policy {
    name   = "${local.step_function_name}-policies"
    policy = data.aws_iam_policy_document.validate_bagit_machine_policies.json
  }
}

data "aws_iam_policy_document" "validate_bagit_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "validate_bagit_machine_policies" {
  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]

    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]

    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid     = "InvokeLambdaPolicy"
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      aws_lambda_function.vb_bagit_checksum_validation.arn,
      aws_lambda_function.vb_files_checksum_validation.arn
    ]
  }

  statement {
    actions = ["sqs:SendMessage"]
    effect  = "Allow"
    resources = [
      var.tdr_sqs_retry_arn
    ]
  }
}

# Lambda Roles

resource "aws_iam_role" "validate_bagit_lambda_invoke_role" {
  name               = "${local.step_function_name}-lambda-invoke-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "validate_bagit_lambda_role_policy" {
  role       = aws_iam_role.validate_bagit_lambda_invoke_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

resource "aws_iam_role" "vb_trigger_lambda" {
  name               = "${var.env}-${var.prefix}-vb-trigger-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  inline_policy {
    name   = "${var.env}-${var.prefix}-vb-trigger"
    policy = data.aws_iam_policy_document.vb_trigger.json
  }
}

resource "aws_iam_role_policy_attachment" "vb_trigger_lambda_sqs" {
  role       = aws_iam_role.vb_trigger_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# Lambda policy documents

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vb_trigger" {
  statement {
    actions   = ["states:StartExecution"]
    effect    = "Allow"
    resources = [aws_sfn_state_machine.validate_bagit.arn]
  }
}

# SQS Policies

data "aws_iam_policy_document" "tre_vb_queue_in" {
  statement {
    actions = ["sqs:SendMessage"]
    effect  = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }
    resources = [
      aws_sqs_queue.tre_vb_in.arn
    ]
  }
}

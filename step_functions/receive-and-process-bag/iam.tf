# Step Function Roles and Policies

resource "aws_iam_role" "receive_and_process_bag" {
  name = "${var.env}-${var.prefix}-receive-and-process-bag-role"
  assume_role_policy = data.aws_iam_policy_document.receive_and_process_bag_assume_role_policy.json
  inline_policy {
    name = "receive-process-bag-policies"
    policy = data.aws_iam_policy_document.receive_and_process_bag_machine_policies.json
  }
}

data "aws_iam_policy_document" "receive_and_process_bag_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "receive_and_process_bag_machine_policies" {
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
    sid = "InvokeLambdaPolicy"
    effect = "Allow"
    actions = [ "lambda:InvokeFunction" ]
    resources = [ 
        
    ]
  }
}

# Lambda Roles and Policies

resource "aws_iam_role" "receive_and_process_bag_lambda_invoke_role" {
  name               = "${var.env}-${var.prefix}-receive-and-process-bag-lambda-invoke-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
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

resource "aws_iam_role_policy_attachment" "receive_and_process_bag_lambda_role_policy" {
  role       = aws_iam_role.receive_and_process_bag_lambda_invoke_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

output "receive_process_bag_lambda_invoke_role" {
  value = aws_iam_role.receive_and_process_bag_lambda_invoke_role.arn
  description = "ARN of the Receive and Process Step Function Lambda Invoke Role"
}

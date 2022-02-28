# Lambda roles and policies

resource "aws_iam_role" "retrieve_bagit_lambda_role" {
  name = "${var.env}-retrieve-bagit"
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

# StateFunction roles and policies

resource "aws_iam_role" "tdr_state_machine_role" {
  name = "${var.env}-retrieve-bagit-machine-role"
  assume_role_policy = data.aws_iam_policy_document.state_function_role_policy.json
  inline_policy {
    name = "${var.env}-state-function-logs-policy"
    policy = data.aws_iam_policy_document.step_function_policies.json
  }
}


data "aws_iam_policy_document" "state_function_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "step_function_policies" {
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

    effect = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets"
            ]

    effect = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "state_fucntion_lambda_policy" {
  statement {
    actions = [ "lambda:InvokeFunction" ]
    effect = "Allow"
    resources = [ aws_lambda_function.retrieve_bagit_function.arn ]
  }
}
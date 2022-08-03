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
        aws_lambda_function.rapb_bagit_checksum_validation.arn,
        aws_lambda_function.rapb_files_checksum_validation.arn
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

resource "aws_iam_role" "receive_and_process_bag_lambda_invoke_role" {
  name               = "${var.env}-${var.prefix}-receive-and-process-bag-lambda-invoke-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "receive_and_process_bag_lambda_role_policy" {
  role       = aws_iam_role.receive_and_process_bag_lambda_invoke_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

resource "aws_iam_role" "rapb_trigger_lambda" {
  name = "${var.env}-${var.prefix}-rapb-trigger-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  inline_policy {
    name = "${var.env}-${var.env}-rapb-trigger"
    policy = data.aws_iam_policy_document.rapb_trigger.json
  }
}

resource "aws_iam_role_policy_attachment" "rapb_trigger_lambda_CW_logs" {
  role = aws_iam_role.rapb_trigger_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
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

data "aws_iam_policy_document" "rapb_trigger" {
  statement {
    actions   = ["states:StartExecution"]
    effect    = "Allow"
    resources = [ aws_sfn_state_machine.receive_and_process_bag.arn ]
  }
}

# SQS Policies

data "aws_iam_policy_document" "tre_rapb_queue_in" {
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
      aws_sqs_queue.tre_rapb_in.arn
    ]
  }
}

# SNS Policies 

data "aws_iam_policy_document" "receive_and_process_bag_out_topic_policy" {
  statement {
    actions = [ "sns:Publish" ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [ aws_sfn_state_machine.receive_and_process_bag.role_arn ]
    }
    resources = [ aws_sns_topic.receive_and_process_bag_out.arn ]
  }
}

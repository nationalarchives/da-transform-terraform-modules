resource "aws_iam_role" "dri_preingest_sip_generation" {
  name = "${var.env}-${var.prefix}-dri-preigest-sip-generation-role"
  assume_role_policy = data.aws_iam_policy_document.dri_preingest_sip_generation_assume_role_policy.json
  inline_policy {
    name = "dri-preingest-sip-generation-policies"
    policy = data.aws_iam_policy_document.dri_preingest_sip_generation_machine_policy.json
  }
}

data "aws_iam_policy_document" "dri_preingest_sip_generation_assume_role_policy" {
  statement {
    actions = [ "sts:AssumeRole" ]

    principals {
      type = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "dri_preingest_sip_generation_machine_policy" {
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
      aws_lambda_function.bagit_to_dri_sip.arn
    ]
  }  
}

# Lambda Roles

# Role for the lambda functions in dri-preingest-sipgeneration step-function
resource "aws_iam_role" "dri_preingest_sip_generation_lambda_role" {
  name = "${var.env}-${var.prefix}-dri-sip-ingest-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "dri_preingest_sip_lambda_logs" {
role = aws_iam_role.dri_preingest_sip_generation_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

# Role for the dri-preingest-sipgeneration step-function trigger
resource "aws_iam_role" "dpsg_trigger" {
  name = "${var.env}-${var.prefix}-dpsg-trigger-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  inline_policy {
    name = "${var.env}-${var.prefix}-dpsg-trigger"
    policy = data.aws_iam_policy_document.dpsg_trigger.json
  }
}

resource "aws_iam_role_policy_attachment" "dpsg_sqs_lambda_trigger" {
  role = aws_iam_role.dpsg_trigger.name
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

data "aws_iam_policy_document" "dpsg_trigger" {
  statement {
    actions   = ["states:StartExecution"]
    effect    = "Allow"
    resources = [ aws_sfn_state_machine.dri_preingest_sip_generation.arn ]
  }
}

# SQS Polciy

data "aws_iam_policy_document" "tre_dpsg_in_queue" {
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
      aws_sqs_queue.tre_dpsg_in.arn
    ]
  }
}

# S3 Policy

data "aws_iam_policy_document" "dpsg_out_bucket" {
  statement {
    actions = [
      "s3:PutObject", 
      "s3:GetObject", 
      "s3:ListBucket", 
    ]

    principals {
      type        = "AWS"
      identifiers = [ aws_iam_role.dri_preingest_sip_generation_lambda_role.arn ]
    }

    resources = ["${aws_s3_bucket.dpsg_out.arn}/*", aws_s3_bucket.dpsg_out.arn]
  }
}

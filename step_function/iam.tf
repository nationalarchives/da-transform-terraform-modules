# Lambda roles and policies

resource "aws_iam_role" "retrieve_bagit_lambda_role" {
  name               = "${var.env}-te-bagit-checksum-validation-lambda-role"
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

resource "aws_iam_role_policy_attachment" "lambda_retrieve_bagit_role_policy" {
  role       = aws_iam_role.retrieve_bagit_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

# S3 Policy

data "aws_iam_policy_document" "tdr_out_bucket_policy" {
  statement {
    actions = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", ]

    principals {
      type        = "AWS"
      identifiers = [aws_lambda_function.retrieve_bagit_function.role]
    }

    resources = ["${aws_s3_bucket.tdr_bagit_out.arn}/*", aws_s3_bucket.tdr_bagit_out.arn]
  }


}

# StateFunction roles and policies

resource "aws_iam_role" "tdr_state_machine_role" {
  name               = "${var.env}-te-state-machine-role"
  assume_role_policy = data.aws_iam_policy_document.state_function_role_policy.json
  inline_policy {
    name   = "${var.env}-state-function-logs-policy"
    policy = data.aws_iam_policy_document.step_function_policies.json
  }
  inline_policy {
    name   = "${var.env}-state-function-lambda-policy"
    policy = data.aws_iam_policy_document.state_fucntion_lambda_policy.json
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
}

data "aws_iam_policy_document" "state_fucntion_lambda_policy" {
  statement {
    actions = ["lambda:InvokeFunction"]
    effect  = "Allow"
    resources = [
      aws_lambda_function.retrieve_bagit_function.arn,
      aws_lambda_function.bagit_files_checksum_function.arn,
      aws_lambda_function.run_judgement_parser.arn
    ]
  }

  statement {
    actions = ["sqs:SendMessage"]
    effect  = "Allow"
    resources = [
      var.tdr_sqs_queue_arn
    ]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
    "kms:GenerateDataKey*", 
    ]
    effect    = "Allow"
    resources = [
      var.tdr_queue_kms_key 
    ]
  }
}

# SNS Policy

data "aws_iam_policy_document" "editorial_sns_topic_policy" {
  statement {
    actions = [ "sns:Publish" ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [ aws_sfn_state_machine.tdr_state_machine.role_arn ]
    }
    resources = [ aws_sns_topic.editorial_sns.arn ]
  }

  statement {
    sid = "SNS Subscription for Editorial"
    actions = [ "sns:Subscribe" ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [ var.editorial_sns_sub_arn ]
    }
    resources = [ aws_sns_topic.editorial_sns.arn ]
  }
}
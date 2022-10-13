resource "aws_sns_topic" "common_tre_slack_alerts" {
  name              = "${var.env}-${var.prefix}-common-slack-alerts"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "common_tre_slack_alerts" {
  arn    = aws_sns_topic.common_tre_slack_alerts.arn
  policy = data.aws_iam_policy_document.common_tre_slack_alerts_sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "common_tre_slack_alerts" {
  topic_arn = aws_sns_topic.common_tre_slack_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.common_tre_slack_alerts.arn
}

# TRE In SNS Topic

resource "aws_sns_topic" "tre_in" {
  name              = "${var.env}-${var.prefix}-in"
  kms_master_key_id = aws_kms_alias.tre_in_sns.name
}

resource "aws_sns_topic_policy" "tre_in" {
  arn    = aws_sns_topic.tre_in.arn
  policy = data.aws_iam_policy_document.tre_in_topic_policy.json
}

resource "aws_sns_topic_subscription" "tre_in" {
  for_each  = { for sub in var.tre_in_subscriptions : sub.name => sub }
  topic_arn = aws_sns_topic.tre_in.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}

# TRE Internal SNS Topic

resource "aws_sns_topic" "tre_internal" {
  name              = "${var.env}-${var.prefix}-internal"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "tre_internal" {
  arn    = aws_sns_topic.tre_internal.arn
  policy = data.aws_iam_policy_document.tre_internal_topic_policy.json
}

resource "aws_sns_topic_subscription" "tre_internal" {
  for_each      = { for sub in var.tre_internal_subscriptions : sub.name => sub }
  topic_arn     = aws_sns_topic.tre_internal.arn
  protocol      = each.value.protocol
  endpoint      = each.value.endpoint
  filter_policy = each.value.filter_policy
}

# TRE Out SNS Topic

resource "aws_sns_topic" "tre_out" {
  name              = "${var.env}-${var.prefix}-out"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "tre_out" {
  arn    = aws_sns_topic.tre_out.arn
  policy = data.aws_iam_policy_document.tre_out_topic_policy.json
}

resource "aws_sns_topic_subscription" "tre_out" {
  for_each  = { for sub in var.tre_out_subscriptions : sub.name => sub }
  topic_arn = aws_sns_topic.tre_out.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}

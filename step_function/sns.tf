resource "aws_sns_topic" "editorial_sns" {
  name = "${var.env}-te-editorial-out"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "editorial_sns_policy" {
  arn = aws_sns_topic.editorial_sns.arn
  policy = data.aws_iam_policy_document.editorial_sns_topic_policy.json
}
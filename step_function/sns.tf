resource "aws_sns_topic" "editorial_sns" {
  name = "${var.env}-te-editorial-out"
  policy = data.aws_iam_policy_document.editorial_sns_topic_policy.json
  kms_master_key_id = "alias/aws/sns"
}

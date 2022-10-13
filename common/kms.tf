resource "aws_kms_key" "tre_in_sns" {
  description             = "This key is used to encrypt ${var.env}-${var.prefix}-in SNS Topic messages"
  enable_key_rotation     = true
  multi_region            = true
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.tre_in_sns_kms_key.json
}

resource "aws_kms_alias" "tre_in_sns" {
  name          = "alias/sns/${var.env}/${var.prefix}-in"
  target_key_id = aws_kms_key.tre_in_sns.key_id
}

resource "aws_sns_topic" "receive_and_process_bag_out" {
  name = "${var.env}-${var.prefix}-receive-and-process-out"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "receive_and_process_bag_out" {
  arn = aws_sns_topic.receive_and_process_bag_out.arn
  policy = ""
}

output "receive_and_process_bag_out_sns_topic" {
  value = aws_sns_topic.receive_and_process_bag_out.arn
}

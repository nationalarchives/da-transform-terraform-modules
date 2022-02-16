resource "aws_s3_bucket" "test_bucket" {
  bucket = var.pipeline_deployment_bucket_name

  force_destroy = true
}
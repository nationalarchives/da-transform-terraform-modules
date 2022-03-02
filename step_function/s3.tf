resource "aws_s3_bucket" "tdr_bagit_out" {
  bucket = "${var.env}-tdr-bagit-out"

}

resource "aws_s3_bucket_policy" "name" {
  bucket = aws_s3_bucket.tdr_bagit_out.bucket
  policy = data.aws_iam_policy_document.tdr_out_bucket_policy.json
}

resource "aws_s3_bucket_acl" "tdr_bagit_out" {
  bucket = aws_s3_bucket.tdr_bagit_out.id
  acl = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tdr_bagit_out" {
  bucket = aws_s3_bucket.tdr_bagit_out.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "tdr_bagit_out" {
  bucket = aws_s3_bucket.tdr_bagit_out.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tdr_bagit_out" {

  bucket                  = aws_s3_bucket.tdr_bagit_out.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}
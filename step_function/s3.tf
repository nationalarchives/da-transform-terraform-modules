# TDR bagit-out-temp Bucket

resource "aws_s3_bucket" "tdr_bagit_out" {
  bucket = "${var.env}-${var.prefix}-temp"

}

resource "aws_s3_bucket_policy" "name" {
  bucket = aws_s3_bucket.tdr_bagit_out.bucket
  policy = data.aws_iam_policy_document.tdr_out_bucket_policy.json
}

resource "aws_s3_bucket_acl" "tdr_bagit_out" {
  bucket = aws_s3_bucket.tdr_bagit_out.id
  acl    = "private"
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


output "tre_temp_bucket" {
  value = aws_s3_bucket.tdr_bagit_out.bucket
  description = "TRE Temp Bucket"
}
# editorial judgment-out bucket

resource "aws_s3_bucket" "editorial_judgment_out" {
  bucket = "${var.env}-${var.prefix}-editorial-judgment-out"

}

resource "aws_s3_bucket_policy" "editorial_judgment_out" {
  bucket = aws_s3_bucket.editorial_judgment_out.bucket
  policy = data.aws_iam_policy_document.editorial_judgment_out_bucket_policy.json
}

resource "aws_s3_bucket_acl" "editorial_judgment_out" {
  bucket = aws_s3_bucket.editorial_judgment_out.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "editorial_judgment_out" {
  bucket = aws_s3_bucket.editorial_judgment_out.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "editorial_judgment_out" {
  bucket = aws_s3_bucket.editorial_judgment_out.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "editorial_judgment_out" {

  bucket                  = aws_s3_bucket.editorial_judgment_out.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}
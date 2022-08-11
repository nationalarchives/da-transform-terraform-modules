locals {
  resource_prefix = "${var.env}-${var.prefix}"
  step_function_name = "${local.resource_prefix}-receive-and-process-bag"
  lambda_name_bagit_validation = "${local.resource_prefix}-rapb-bagit-checksum-validation"
  lambda_name_files_validation = "${local.resource_prefix}-rapb-files-checksum-validation"
  lambda_name_trigger = "${local.resource_prefix}-rapb-trigger"
}

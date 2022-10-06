locals {
  resource_prefix              = "${var.env}-${var.prefix}"
  step_function_name           = "${local.resource_prefix}-validate-bagit"
  lambda_name_bagit_validation = "${local.resource_prefix}-vb-bagit-validation"
  lambda_name_files_validation = "${local.resource_prefix}-vb-bagit-files-validation"
  lambda_name_trigger          = "${local.resource_prefix}-vb-trigger"
}

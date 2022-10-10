locals {
  resource_prefix              = "${var.env}-${var.prefix}"
  step_function_name           = "${local.resource_prefix}-dri-preingest-sip-generation"
  lambda_name_bagit_to_dri_sip = "${local.resource_prefix}-bagit-to-dri-sip"
  lambda_name_trigger          = "${local.resource_prefix}-dpsg-trigger"
}

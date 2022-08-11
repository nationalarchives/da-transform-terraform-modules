locals {
  resource_prefix = "${var.env}-${var.prefix}"
  step_function_name = "${resource_prefix}-receive-and-process-bag"
}

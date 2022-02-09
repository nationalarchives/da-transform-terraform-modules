terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.74.0"
    }
  }
}

data "aws_caller_identity" "aws" {}

resource "aws_iam_user" "moduleuser" {
  for_each = { for user in var.users: user.name => user }
  name = each.value.name
  path = "/"
}

#tfsec:ignore:aws-iam-enforce-mfa ignore this group for this test as its intentionally not going to require mfa
resource "aws_iam_group" "all_users" {
	name = "all_users"
}

resource "aws_iam_user_group_membership" "allusers" {
  for_each = aws_iam_user.moduleuser
  user = each.value.name
  groups = [ 
		aws_iam_group.all_users.name
  ]
}

resource "aws_iam_group_policy" "manage_own_creds" {
	name = "manage_own_creds"
  group = aws_iam_group.all_users.name

	policy = templatefile("${path.module}/selfmanagepolicy.json.tftpl",
    {
      accountnumber = data.aws_caller_identity.aws.account_id
    })
}

resource "aws_iam_group" "modulegroups" {
  for_each = { for group in var.groups: group.name => group }
  name = each.value.name
  path = "/"
}

resource "aws_iam_user_group_membership" "moduleuser" {
  for_each = { for user in var.users: user.name => user }
  user = each.key

  groups = each.value.groups

  # we allow user group membership to be specified, this could include groups outside
  # terraform but we should ensure any groups created are provisioned before this runs
  depends_on = [
    aws_iam_group.modulegroups,
  ]
}

data "aws_iam_policy_document" "group_policy" {
  for_each = { for group in var.groups: group.name => group }
  statement {
    sid = "1"
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    condition { 
      test = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values = [ "true" ] 
    }
    resources = each.value.rolearns
  }
}

resource "aws_iam_group_policy" "group_policy" {
  for_each = { for group in var.groups: group.name => group }
  name = each.key
  group = aws_iam_group.modulegroups[each.key].name
  policy = data.aws_iam_policy_document.group_policy[each.key].json
}

output "users" {
  value = {
    for user in aws_iam_user.moduleuser: user.name => user.arn
  }
}

output "groups" {
  value = {
    for group in aws_iam_group.modulegroups: group.name => group.arn
  }
}

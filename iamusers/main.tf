terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.74.0"
    }
  }
}

resource "aws_iam_user" "moduleuser" {
  for_each = var.users
  name = each.value.name
  path = "/"
}

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

	policy = file("${path.module}/selfmanagepolicy.json")
}

resource "aws_iam_group" "modulegroups" {
  for_each = var.groups
  name = each.value.name
  path = "/"
}

data "aws_iam_policy_document" "group_policy" {
  for_each = var.groups
  statement {
    sid = "1"
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    resources = each.value.rolearns
  }
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

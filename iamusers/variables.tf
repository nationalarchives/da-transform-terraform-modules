variable "groups" {
  description = "List of groups to be provisioned"
  type = list(object({
    name = string
    rolearns = list(string)
  }))
}

variable "users" {
  description = "List of users to provision and their group memberships"
  type = list(object({
    name = string
    groups = list(string)
  }))
}

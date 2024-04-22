data "authentik_groups" "meta-children" {
  attributes = jsonencode({
    gitlab = {
      add_to_meta = true
    }
  })
}

resource "gitlab_group" "meta" {
  name             = "Meta"
  path             = "meta"
  visibility_level = "internal"

  emails_enabled          = false
  mentions_disabled       = true
  project_creation_level  = "noone"
  subgroup_creation_level = "owner"
  request_access_enabled  = false
}

resource "gitlab_group" "meta-children" {
  for_each = toset([for group in data.authentik_groups.meta-children.groups : replace(group.name, "/^gitlab_/", "")])

  name             = each.key
  path             = each.key
  parent_id        = gitlab_group.meta.id
  visibility_level = "internal"

  emails_enabled          = false
  project_creation_level  = "noone"
  subgroup_creation_level = "owner"
  request_access_enabled  = false
}

resource "gitlab_group_membership" "meta-children" {
  for_each = merge([
    for group in data.authentik_groups.meta-children.groups : {
      for user in group.users_obj :
      "${group.name}_${user.username}" => {
        group_id = gitlab_group.meta-children[replace(group.name, "/^gitlab_/", "")].id
        user_id  = gitlab_user.users[user.username].id
      }
    }
  ]...)

  group_id     = each.value.group_id
  user_id      = each.value.user_id
  access_level = "developer"
}

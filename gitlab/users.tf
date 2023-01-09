data "authentik_group" "gitlab" {
  name = "gitlab"
}

data "authentik_group" "gitlab_admins" {
  name = "gitlab_admins"
}

data "authentik_group" "gitlab_externals" {
  name = "gitlab_externals"
}

data "authentik_user" "gitlab" {
  for_each = { for user in data.authentik_group.gitlab.users_obj : user.username => user }
  pk = each.value.pk
}

resource "random_password" "users" {
  for_each = { for user in data.authentik_group.gitlab.users_obj : user.username => user }

  length  = 32
  special = true
}

resource "gitlab_user" "users" {
  for_each = { for user in data.authentik_group.gitlab.users_obj : user.username => user }

  username          = each.key
  name              = each.value.name
  email             = each.value.email
  password          = random_password.users[each.key].result
  skip_confirmation = true
  is_admin          = contains(data.authentik_group.gitlab_admins.users, each.value.pk)
  can_create_group  = contains(data.authentik_group.gitlab_admins.users, each.value.pk)
  is_external       = contains(data.authentik_group.gitlab_externals.users, each.value.pk)
  projects_limit    = try(jsondecode(each.value.attributes)["gitlab"]["project_limit"], 25)

  lifecycle {
    ignore_changes = [password]
  }
}

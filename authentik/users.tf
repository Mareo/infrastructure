locals {
  users = {
    "mareo" = {
      name  = "Marin Hannache"
      email = "mareo@mareo.fr"
      attributes = {
        nextcloud_quota = "none"
      }
      groups = [
        "argocd_admins",
        "gitlab_admins",
        "nextcloud_admins",
        "vault_admins",
      ]
      is_admin = true
    }
  }
}

resource "authentik_user" "users" {
  for_each = local.users
  username = each.key
  name     = each.value.name
  email    = each.value.email
  groups = concat(
    [for g in try(each.value.groups, []) : authentik_group.groups[g].id],
    try(each.value.is_admin, false) ? [data.authentik_group.admins.id] : []
  )
  is_active  = try(each.value.is_active, true)
  attributes = jsonencode(try(each.value.attributes, {}))
}

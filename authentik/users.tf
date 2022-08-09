locals {
  users = {
    "mareo" = {
      name  = "Marin Hannache"
      email = "mareo@mareo.fr"
      attributes = {
        nextcloud_quota = "none"
        allowed_emails = [
          "@mareo.fr",
          "marin@hannache.fr",
        ]
      }
      groups = [
        "mail",
        "argocd_admins",
        "gitlab_admins",
        "kubernetes_admins",
        "nextcloud_admins",
        "vault_admins",
      ]
      is_admin = true
    }
    "lea" = {
      name  = "Léa Assako"
      email = "assakolea@gmail.com"
      attributes = {
        nextcloud_quota = "10G"
      }
      groups = [
        "gitlab",
        "nextcloud",
      ]
    }
    "deadeye" = {
      name  = "DeadEye"
      email = "eric.ly.perso@gmail.com"
      groups = [
        "argocd",
        "argocd_petitstream",
        "argocd_petitstream_ops",
      ]
    }
    "drummyjohn" = {
      name  = "DrummyJohn"
      email = "jonathan.monnet28@gmail.com"
      groups = [
        "argocd",
        "argocd_petitstream",
        "argocd_petitstream_ops",
      ]
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

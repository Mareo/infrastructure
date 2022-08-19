locals {
  users = {
    "mareo" = {
      name  = "Marin Hannache"
      email = "mareo@mareo.fr"
      path  = "users/family"
      attributes = {
        nextcloud_quota = "none"
        allowed_emails = [
          "@mareo.fr",
          "marin@hannache.fr",
        ]
      }
      groups = [
        "alertmanager",
        "argocd_admins",
        "gitlab_admins",
        "grafana",
        "grafana_editors",
        "grafana_admins",
        "hedgedoc",
        "kubernetes_admins",
        "mail",
        "nextcloud_admins",
        "petitstream_admins",
        "petitstream_devs",
        "petitstream_ops",
        "prometheus",
        "vault_admins",
        "vaultwarden",
      ]
      is_admin = true
    }
    "lea" = {
      name  = "Léa Assako"
      email = "assakolea@gmail.com"
      path  = "users/family"
      attributes = {
        nextcloud_quota = "10G"
      }
      groups = [
        "gitlab",
        "hedgedoc",
        "nextcloud",
        "vaultwarden",
      ]
    }
    "deadeye" = {
      name  = "DeadEye"
      email = "eric.ly.perso@gmail.com"
      path  = "users/petitstream"
      groups = [
        "gitlab",
        "grafana",
        "hedgedoc",
        "petitstream_devs",
        "petitstream_ops",
      ]
    }
    "drummyjohn" = {
      name  = "DrummyJohn"
      email = "jonathan.monnet28@gmail.com"
      path  = "users/petitstream"
      groups = [
        "gitlab",
        "grafana",
        "hedgedoc",
        "petitstream_devs",
        "petitstream_ops",
      ]
    }
    "sharpii" = {
      name  = "shARPII"
      email = "philippe.grad@gmail.com"
      path  = "users/petitstream"
      groups = [
        "gitlab",
        "grafana",
        "hedgedoc",
        "petitstream_devs",
        "petitstream_ops",
      ]
    }
    "superjp" = {
      name  = "superjp"
      email = "streampetit@gmail.com"
      path  = "users/petitstream"
      groups = [
        "gitlab",
        "grafana",
        "hedgedoc",
        "petitstream_admins",
        "petitstream_devs",
      ]
    }
  }
}

resource "authentik_user" "users" {
  for_each = local.users
  username = each.key
  name     = each.value.name
  email    = each.value.email
  path     = try(each.value.path, "users")
  groups = concat(
    [for g in try(each.value.groups, []) : authentik_group.groups[g].id],
    try(each.value.is_admin, false) ? [data.authentik_group.admins.id] : []
  )
  is_active  = try(each.value.is_active, true)
  attributes = jsonencode(try(each.value.attributes, {}))
}

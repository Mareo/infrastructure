locals {
  users = {
    "mareo" = {
      name  = "Marin Hannache"
      email = "mareo@mareo.fr"
      path  = "users/family"
      attributes = {
        nextcloud_quota = "none"
        gitlab = {
          project_limit = 100
        }
        settings = {
          locale = "en"
        }
        mailboxRules = [
          "@mareo.fr:mareo@mareo.fr",
        ]
        mailboxes = [
          "mareo@mareo.fr",
          "marin@hannache.fr",
          "marin@theseusformation.fr",
        ]
        allowedEmails = [
          "@mareo.fr",
          "@theseusformation.fr",
          "marin@hannache.fr",
        ]
        dovecotAclGroups     = "mareo,theseus"
        dovecotQuotaStorage  = "10G"
        dovecotQuotaMessages = 250000
      }
      groups = [
        "alertmanager",
        "argocd",
        "argocd_admins",
        "gatus",
        "gitlab",
        "gitlab_admins",
        "gitlab_petitstream",
        "gitlab_theseus",
        "grafana",
        "grafana_editors",
        "grafana_admins",
        "hedgedoc",
        "kubernetes_admins",
        "mail",
        "moodle",
        "moodle_managers",
        "moodle_admins",
        "nextcloud",
        "nextcloud_admins",
        "paperless",
        "petitstream_admins",
        "petitstream_devs",
        "petitstream_ops",
        "prometheus",
        "proxmox",
        "syncthing",
        "theseus",
        "theseus_ops",
        "vault",
        "vault_admins",
        "vault_theseus",
        "vaultwarden",
      ]
      is_admin = true
    }
    "lea" = {
      name  = "Léa Assako"
      email = "assakolea@gmail.com"
      path  = "users/family"
      attributes = {
        nextcloud_quota = "100G"
      }
      groups = [
        "gitlab",
        "hedgedoc",
        "nextcloud",
        "paperless",
        "syncthing",
        "vaultwarden",
      ]
    }
    "kamre" = {
      name  = "Kamre Hannache"
      email = "kamre@hannache.fr"
      path  = "users/family"
      attributes = {
        nextcloud_quota = "50G"
        settings = {
          locale = "fr_FR"
        }
        mailboxes = [
          "kamre@hannache.fr",
        ]
        allowedEmails = [
          "kam@hannache.fr",
          "kamre@hannache.fr",
          "karl@hannache.fr",
        ]
        mailAliases = [
          "kam@hannache.fr",
          "karl@hannache.fr",
        ]
        dovecotQuotaStorage  = "10G"
        dovecotQuotaMessages = 250000
      }
      groups = [
        "hedgedoc",
        "mail",
        "nextcloud",
        "vaultwarden",
      ]
    }
    "Barba" = {
      name  = "Sébastien Mermet"
      email = "seb.mermet@orange.fr"
      path  = "users/friends"
      attributes = {
        nextcloud_quota = "100G"
      }
      groups = [
        "hedgedoc",
        "nextcloud",
        "vaultwarden",
      ]
    }
    "chewie" = {
      name  = "Kévin Sztern"
      email = "contact@kevinsztern.fr"
      path  = "users/friends"
      attributes = {
        nextcloud_quota = "50G"
        mailboxes = [
          "kevin@theseusformation.fr",
        ]
        allowedEmails = [
          "@theseusformation.fr",
        ]
        dovecotAclGroups     = "theseus"
        dovecotQuotaStorage  = "10G"
        dovecotQuotaMessages = 250000
      }
      groups = [
        "argocd",
        "gitlab",
        "gitlab_theseus",
        "hedgedoc",
        "mail",
        "moodle",
        "moodle_teachers",
        "moodle_managers",
        "moodle_admins",
        "nextcloud",
        "theseus",
        "theseus_ops",
        "vault",
        "vault_theseus",
        "vaultwarden",
      ]
    }
    "deadeye" = {
      name  = "DeadEye"
      email = "eric.ly.perso@gmail.com"
      path  = "users/petitstream"
      groups = [
        "gitlab",
        "gitlab_petitstream",
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
  type     = "internal"
  path     = try(each.value.path, "users")
  groups = concat(
    [for g in try(each.value.groups, []) : authentik_group.groups[g].id],
    try(each.value.is_admin, false) ? [data.authentik_group.admins.id] : []
  )
  is_active  = try(each.value.is_active, true)
  attributes = jsonencode(try(each.value.attributes, {}))
}

data "vault_generic_secret" "authentik_notifications" {
  path = "k8s/authentik/notifications"
}

resource "authentik_event_transport" "discord" {
  name        = "discord"
  mode        = "webhook_slack"
  send_once   = true
  webhook_url = data.vault_generic_secret.authentik_notifications.data["webhook"]
}

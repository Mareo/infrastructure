resource "random_password" "argocd_webhook-token_gitlab" {
  length  = 64
  special = false
}

resource "random_password" "argocd_webhook-token_github" {
  length  = 64
  special = false
}

resource "vault_generic_secret" "argocd_webhook-token" {
  path = "k8s/argocd/webhooks"
  data_json = jsonencode({
    "webhook.gitlab.secret" = random_password.argocd_webhook-token_gitlab.result
    "webhook.github.secret" = random_password.argocd_webhook-token_github.result
  })
}

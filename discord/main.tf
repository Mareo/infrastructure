terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.24.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    discord = {
      source  = "Lucky3028/discord"
      version = "1.6.1"
    }
  }

  backend "s3" {
    key = "discord"
  }
}

provider "vault" {
  address = yamldecode(file("../config.yml")).vault_addr
}

locals {
  server_icon_path = "icons/server.jpg"
  admins = [
    "198449809751932929",
  ]
  channels = {
    "Infrastructure" = [
      {
        name = "alertmanager"
        type = "text"
        webhooks = [
          {
            avatar_path = "icons/prometheus.png"
            name        = "Alertmanager"
            url_attr    = "slack_url"
            vault_path  = "k8s/kube-prometheus-stack/alertmanager/discord"
          },
        ]
      },
      {
        name = "authentik"
        type = "text"
        webhooks = [
          {
            avatar_path = "icons/authentik.png"
            name        = "Authentik"
            url_attr    = "slack_url"
            vault_path  = "k8s/authentik/notifications"
          },
        ]
      },
      {
        name = "argo-cd"
        type = "text"
        webhooks = [
          {
            avatar_path = "icons/argo-cd.png"
            name        = "Argo CD"
            vault_key   = "webhook"
            vault_path  = "k8s/argocd/notifications"
          },
        ]
      },
      {
        name = "gatus"
        type = "text"
        webhooks = [
          {
            avatar_path = "icons/gatus.png"
            name        = "Gatus"
            vault_key   = "DISCORD_WEBHOOK"
            vault_path  = "k8s/gatus/discord"
          },
        ]
      },
      {
        name = "gitlab"
        type = "text"
        webhooks = [
          {
            avatar_path = "icons/gitlab.png"
            name        = "GitLab"
            url_attr    = "slack_url"
            vault_key   = "gitlab-iac"
            vault_path  = "discord/webhooks"
          },
        ]
      },
    ]
    "Petitstream" = [
      {
        name = "argo-cd"
        type = "text"
        webhooks = [
          {
            avatar_path = "icons/argo-cd.png"
            name        = "Argo CD"
            vault_key   = "webhook-petitstream"
            vault_path  = "k8s/argocd/notifications"
          },
        ]
      },
      {
        name = "gatus",
        type = "text"
        webhooks = [
          {
            avatar_path = "icons/gatus.png"
            name        = "Gatus"
            vault_key   = "DISCORD_WEBHOOK_PETITSTREAM"
            vault_path  = "k8s/gatus/discord"
          },
        ]
      },
      {
        name = "gitlab",
        type = "text"
        webhooks = [
          {
            avatar_path = "icons/gitlab.png"
            name        = "GitLab"
            url_attr    = "slack_url"
            vault_key   = "gitlab-petitstream"
            vault_path  = "discord/webhooks"
          },
        ]
      },
    ]
  }
}

data "vault_kv_secret_v2" "terraform" {
  mount = "discord"
  name  = "terraform"
}

provider "discord" {
  token = data.vault_kv_secret_v2.terraform.data["token"]
}

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.16.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    discord = {
      source  = "Lucky3028/discord"
      version = "1.4.0"
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
            vault_path  = "k8s/kube-prometheus-stack/alertmanager/discord"
            url_attr    = "slack_url"
            name        = "Alertmanager"
            avatar_path = "icons/prometheus.png"
          },
        ]
      },
      {
        name = "argo-cd"
        type = "text"
        webhooks = [
          {
            vault_path  = "k8s/argocd/notifications"
            vault_key   = "webhook"
            name        = "Argo CD"
            avatar_path = "icons/argo-cd.png"
          },
        ]
      },
      {
        name = "gatus"
        type = "text"
        webhooks = [
          {
            vault_path  = "k8s/gatus/discord"
            vault_key   = "DISCORD_WEBHOOK"
            name        = "Gatus"
            avatar_path = "icons/gatus.png"
          },
        ]
      },
      {
        name = "gitlab"
        type = "text"
        webhooks = [
          {
            vault_path  = "discord/webhooks"
            vault_key   = "gitlab-iac"
            name        = "GitLab"
            avatar_path = "icons/gitlab.png"
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
            vault_path  = "k8s/argocd/notifications"
            vault_key   = "webhook-petitstream"
            name        = "Argo CD"
            avatar_path = "icons/argo-cd.png"
          },
        ]
      },
      {
        name = "gatus",
        type = "text"
        webhooks = [
          {
            vault_path  = "k8s/gatus/discord"
            vault_key   = "DISCORD_WEBHOOK_PETITSTREAM"
            name        = "Gatus"
            avatar_path = "icons/gatus.png"
          },
        ]
      },
      {
        name = "gitlab",
        type = "text"
        webhooks = [
          {
            vault_path  = "discord/webhooks"
            vault_key   = "gitlab-petitstream"
            name        = "GitLab"
            avatar_path = "icons/gitlab.png"
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

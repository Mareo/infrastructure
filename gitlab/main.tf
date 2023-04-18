terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.15.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "15.10.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.4.0"
    }
  }

  backend "s3" {
    key = "gitlab"
  }
}

provider "vault" {
  address = yamldecode(file("../config.yml")).vault_addr
}

provider "gitlab" {
  base_url = yamldecode(file("../config.yml")).gitlab_addr
  token    = trimspace(file("../secrets/gitlab_token"))
}

provider "authentik" {
  url   = "https://auth.mareo.fr"
  token = trimspace(file("../secrets/authentik_token"))
}

data "gitlab_user" "root" {
  username = "root"
}

resource "gitlab_personal_access_token" "root_terraform" {
  user_id = data.gitlab_user.root.id
  name    = "terraform"
  scopes  = ["api"]

  lifecycle {
    ignore_changes = [
      scopes,
    ]
  }
}

resource "local_sensitive_file" "gitlab-token" {
  content  = gitlab_personal_access_token.root_terraform.token
  filename = "${path.root}/../secrets/gitlab_token"
}

data "vault_generic_secret" "argocd_webhook-token" {
  path = "k8s/argocd/webhooks"
}

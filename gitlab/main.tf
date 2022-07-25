terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.16.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }

  backend "s3" {
    key = "gitlab"
  }
}

provider "gitlab" {
  base_url = yamldecode(file("../config.yml")).gitlab_addr
  token    = trimspace(file("../secrets/gitlab_token"))
}

data "gitlab_user" "root" {
  username = "root"
}

resource "gitlab_personal_access_token" "root_terraform" {
  user_id = data.gitlab_user.root.id
  name    = "terraform"
  scopes  = ["api"]
}

resource "local_sensitive_file" "gitlab-token" {
  content  = gitlab_personal_access_token.root_terraform.token
  filename = "${path.root}/../secrets/gitlab_token"
}

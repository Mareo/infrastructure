resource "random_password" "kargo" {
  length  = 32
  special = true
}

resource "gitlab_user" "kargo" {
  name             = "Kargo"
  username         = "kargo"
  password         = random_password.kargo.result
  email            = "no-reply@kargo.mareo.fr"
  is_admin         = false
  can_create_group = false
  is_external      = false
  reset_password   = false
}

resource "gpg_private_key" "kargo" {
  name     = gitlab_user.kargo.name
  email    = gitlab_user.kargo.email
  rsa_bits = 4096
}

resource "gitlab_user_gpgkey" "kargo" {
  user_id = gitlab_user.kargo.id
  key     = gpg_private_key.kargo.public_key
}

resource "vault_generic_secret" "gitlab_kargo_gpg_key" {
  path = "k8s/kargo/git-client"
  data_json = jsonencode({
    signingKey = gpg_private_key.kargo.private_key
  })
}

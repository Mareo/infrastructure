resource "vault_identity_group" "admins" {
  name     = "admins"
  type     = "external"
  policies = ["admin"]

  metadata = {
    version = "1"
  }
}

resource "vault_identity_group" "theseus" {
  name     = "theseus"
  type     = "external"
  policies = ["theseus"]

  metadata = {
    version = "1"
  }
}

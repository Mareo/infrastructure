resource "vault_identity_group" "admins" {
  name     = "admins"
  type     = "external"
  policies = [vault_policy.admin.name]

  metadata = {
    version = "1"
  }
}

resource "vault_identity_group" "theseus" {
  name     = "theseus"
  type     = "external"
  policies = [vault_policy.theseus_admin.name]

  metadata = {
    version = "1"
  }
}

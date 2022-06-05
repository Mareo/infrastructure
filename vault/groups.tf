resource "vault_identity_group" "vault_admins" {
  name     = "vault_admins"
  type     = "external"
  policies = ["admin"]

  metadata = {
    version = "1"
  }
}

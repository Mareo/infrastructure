resource "vault_identity_group" "admins" {
  name     = "admins"
  type     = "external"
  policies = ["admin"]

  metadata = {
    version = "1"
  }
}

resource "vault_mount" "theseus" {
  path = "theseus"
  type = "kv"
  options = {
    version = 2
  }
}

resource "vault_policy" "theseus" {
  name = "theseus"

  policy = <<-EOT
    path "${vault_mount.theseus.path}/*" {
      capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
    }
    path "${vault_mount.gitlab.path}/theseus/*" {
      capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
    }
    EOT
}

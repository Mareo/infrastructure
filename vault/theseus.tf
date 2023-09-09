resource "vault_mount" "theseus" {
  path = "theseus"
  type = "kv"
  options = {
    version = 2
  }
}

resource "vault_policy" "theseus_admin" {
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

resource "vault_policy" "theseus_external-secrets-operator" {
  name = "theseus_external-secrets-operator"

  policy = <<-EOT
    path "${vault_mount.theseus.path}/data/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "theseus_external-secrets-operator" {
  backend                          = vault_auth_backend.k8s.path
  role_name                        = "theseus_external-secrets-operator"
  bound_service_account_names      = [local.sa_name]
  bound_service_account_namespaces = [local.sa_namespace]
  token_policies                   = [vault_policy.theseus_external-secrets-operator.name]
  token_ttl                        = 24 * 60 * 60 # 24h
  token_bound_cidrs                = []
}

resource "vault_mount" "theseus" {
  path = "theseus"
  type = "kv"
  options = {
    version = 2
  }
}

data "vault_policy_document" "theseus_admin" {
  rule {
    path         = "${vault_mount.theseus.path}/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${vault_mount.gitlab.path}/data/theseus/*"
    capabilities = ["create", "read", "update", "patch", "delete"]
  }

  rule {
    path         = "${vault_mount.gitlab.path}/metadata/theseus/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${vault_mount.gitlab.path}/subkeys/theseus/*"
    capabilities = ["read"]
  }

  rule {
    path         = "${vault_mount.gitlab.path}/delete/theseus/*"
    capabilities = ["create", "update"]
  }

  rule {
    path         = "${vault_mount.gitlab.path}/undelete/theseus/*"
    capabilities = ["create", "update"]
  }

  rule {
    path         = "${vault_mount.gitlab.path}/destroy/theseus/*"
    capabilities = ["create", "update"]
  }
}

resource "vault_policy" "theseus_admin" {
  name   = "theseus"
  policy = data.vault_policy_document.theseus_admin.hcl
}

data "vault_policy_document" "theseus_external-secrets-operator" {
  rule {
    path         = "${vault_mount.theseus.path}/data/*"
    capabilities = ["read"]
  }

  rule {
    path         = "${vault_mount.theseus.path}/metadata/*"
    capabilities = ["read", "list"]
  }
}

resource "vault_policy" "theseus_external-secrets-operator" {
  name = "theseus_external-secrets-operator"

  policy = data.vault_policy_document.theseus_external-secrets-operator.hcl
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

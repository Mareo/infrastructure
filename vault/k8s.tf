locals {
  sa_name      = "vault-secrets-operator"
  sa_namespace = "vault-secrets-operator"
}

data "kubernetes_service_account" "vault-secrets-operator" {
  metadata {
    name      = local.sa_name
    namespace = local.sa_namespace
  }
}

data "kubernetes_secret" "vault-secrets-operator" {
  metadata {
    name      = data.kubernetes_service_account.vault-secrets-operator.default_secret_name
    namespace = local.sa_namespace
  }

  binary_data = {
    "ca.crt" = ""
    "token"  = ""
  }
}

resource "vault_mount" "k8s" {
  path = "k8s"
  type = "kv"
  options = {
    version = 2
  }
}

resource "vault_auth_backend" "k8s" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend            = vault_auth_backend.k8s.path
  kubernetes_host    = "https://kubernetes.default.svc.cluster.local"
  kubernetes_ca_cert = base64decode(data.kubernetes_secret.vault-secrets-operator.binary_data["ca.crt"])
  token_reviewer_jwt = base64decode(data.kubernetes_secret.vault-secrets-operator.binary_data.token)
  issuer             = "https://kubernetes.default.svc.cluster.local"
}

resource "vault_policy" "k8s_vault-secrets-operator" {
  name = "k8s_vault-secrets-operator"

  policy = <<-EOT
    path "${vault_mount.k8s.path}/data/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "k8s_vault-secrets-operator" {
  backend                          = vault_auth_backend.k8s.path
  role_name                        = "k8s_vault-secrets-operator"
  bound_service_account_names      = [local.sa_name]
  bound_service_account_namespaces = [local.sa_namespace]
  token_policies                   = [vault_policy.k8s_vault-secrets-operator.name]
  token_ttl                        = 24 * 60 * 60 # 24h
}

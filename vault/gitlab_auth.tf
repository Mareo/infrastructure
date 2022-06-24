resource "vault_mount" "gitlab" {
  path = "gitlab"
  type = "kv"
  options = {
    version = 2
  }
}

resource "vault_jwt_auth_backend" "gitlab-jwt" {
  path         = "gitlab-jwt"
  jwks_url     = "https://gitlab.mareo.fr/-/jwks"
  bound_issuer = "gitlab.mareo.fr"
  default_role = "gitlab-ci"
}

resource "vault_jwt_auth_backend_role" "gitlab-jwt" {
  role_type = "jwt"
  role_name = "gitlab-ci"
  backend   = vault_jwt_auth_backend.gitlab-jwt.path

  token_policies    = ["default", "gitlab-ci"]
  token_bound_cidrs = []
  token_max_ttl     = 60 * 60 * 2 # 2h

  user_claim        = "sub"
  bound_claims_type = "string"
  bound_claims = {
    ref_protected = "true"
  }

  claim_mappings = {
    namespace_id   = "namespace_id"
    namespace_path = "namespace_path"
    project_id     = "project_id"
    project_path   = "project_path"
    user_id        = "user_id"
    user_login     = "user_login"
    user_email     = "user_email"
    pipeline_id    = "pipeline_id"
    job_id         = "job_id"
    ref            = "ref"
    environment    = "environment"
  }
}

resource "vault_policy" "gitlab_ci" {
  name = "gitlab-ci"

  policy = <<-EOT
    path "${vault_mount.gitlab.path}/data/groups/{{ identity.entity.alias.${vault_jwt_auth_backend.gitlab-jwt.accessor}.metadata.namespace_path }}/*" {
      capabilities = ["read"]
    }

    path "${vault_mount.gitlab.path}/data/projects/{{ identity.entity.alias.${vault_jwt_auth_backend.gitlab-jwt.accessor}.metadata.project_path }}/*" {
      capabilities = ["read"]
    }
  EOT
}

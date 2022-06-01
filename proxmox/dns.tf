locals {
  dns_cnames = toset([
    "api.k8s.mareo.fr.",
    "argocd.mareo.fr.",
    "auth.mareo.fr.",
    "nextcloud.mareo.fr.",
    "vault.mareo.fr.",
    "vaultwarden.mareo.fr.",

    # Gitlab
    "gitlab.mareo.fr.",
    "kas.mareo.fr.",
    "minio.mareo.fr.",
    "pages.mareo.fr.",
    "registry.mareo.fr.",
    "smartcard.mareo.fr.",
  ])
}

resource "dns_cname_record" "dns" {
  zone = "mareo.fr."
  name = trimsuffix(each.key, ".mareo.fr.")

  for_each = local.dns_cnames

  cname = "athena.mareo.fr."
}

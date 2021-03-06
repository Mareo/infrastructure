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
    "registry.mareo.fr.",
    "smartcard.mareo.fr.",
  ])

  dns_a = {
    # Gitlab
    "pages.mareo.fr."   = "65.108.17.229"
    "*.pages.mareo.fr." = "65.108.17.229"
  }
}

resource "dns_cname_record" "dns" {
  for_each = local.dns_cnames

  zone  = "mareo.fr."
  name  = trimsuffix(each.key, ".mareo.fr.")
  cname = "athena.mareo.fr."
}

resource "dns_a_record_set" "dns" {
  for_each = local.dns_a

  zone = "mareo.fr."
  name = trimsuffix(each.key, ".mareo.fr.")
  addresses = [
    each.value
  ]
}

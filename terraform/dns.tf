locals {
  dns_cnames = toset([
    "argocd.mareo.fr.",
    "auth.mareo.fr.",
    "vault.mareo.fr.",
  ])
}

resource "dns_cname_record" "dns" {
  zone = "mareo.fr."
  name = trimsuffix(each.key, ".mareo.fr.")

  for_each = local.dns_cnames

  cname = "athena.mareo.fr."
}

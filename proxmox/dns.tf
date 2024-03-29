locals {
  dns_cnames = toset([
    "api.k8s.mareo.fr.",
  ])

  dns_a = {
    # Gitlab
    "pages.mareo.fr."   = "148.251.4.90"
    "*.pages.mareo.fr." = "148.251.4.90"
  }

  dns_mx = {
    "mareo.fr." = [{
      preference = 10
      exchange   = "ouranos.mareo.fr."
    }]
    "gitlab.mareo.fr." = [{
      preference = 10
      exchange   = "ouranos.mareo.fr."
    }]
    "ouranos.mareo.fr." = [{
      preference = 10
      exchange   = "ouranos.mareo.fr."
    }]
  }
}

resource "dns_cname_record" "dns" {
  for_each = local.dns_cnames

  zone  = "mareo.fr."
  name  = trimsuffix(each.key, ".mareo.fr.")
  cname = "ouranos.mareo.fr."
}

resource "dns_a_record_set" "dns" {
  for_each = local.dns_a

  zone = "mareo.fr."
  name = trimsuffix(each.key, ".mareo.fr.")
  addresses = [
    each.value
  ]
}

resource "dns_mx_record_set" "dns" {
  for_each = local.dns_mx

  zone = "mareo.fr."
  name = each.key != "mareo.fr." ? trimsuffix(each.key, ".mareo.fr.") : null

  dynamic "mx" {
    for_each = each.value
    content {
      preference = mx.value.preference
      exchange   = mx.value.exchange
    }
  }
}

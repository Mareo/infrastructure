locals {
  dns_cnames = toset([
    "api.k8s.mareo.fr.",
  ])

  dns_a = {
    # Gitlab
    "pages.mareo.fr."   = "148.251.4.90"
    "*.pages.mareo.fr." = "148.251.4.90"
  }

  zones = ["mareo.fr", "theseus.fr", "theseusformation.fr"]

  dns_mx = {
    "mareo.fr." = {
      zone = "mareo.fr."
      records = [{
        preference = 10
        exchange   = "ouranos.mareo.fr."
      }]
    }
    "documents.mareo.fr." = {
      zone = "mareo.fr."
      records = [{
        preference = 10
        exchange   = "ouranos.mareo.fr."
      }]
    }
    "gitlab.mareo.fr." = {
      zone = "mareo.fr."
      records = [{
        preference = 10
        exchange   = "ouranos.mareo.fr."
      }]
    }
    "hannache.fr." = {
      zone = "hannache.fr."
      records = [{
        preference = 10
        exchange   = "ouranos.mareo.fr."
      }]
    }
    "ouranos.mareo.fr." = {
      zone = "mareo.fr."
      records = [{
        preference = 10
        exchange   = "ouranos.mareo.fr."
      }]
    }
    "theseus.fr." = {
      zone = "theseus.fr."
      records = [{
        preference = 10
        exchange   = "ouranos.mareo.fr."
      }]
    }
    "theseusformation.fr." = {
      zone = "theseusformation.fr."
      records = [{
        preference = 10
        exchange   = "ouranos.mareo.fr."
      }]
    }
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

  zone = each.value.zone
  name = each.key != each.value.zone ? trimsuffix(each.key, ".${each.value.zone}") : null

  dynamic "mx" {
    for_each = each.value.records
    content {
      preference = mx.value.preference
      exchange   = mx.value.exchange
    }
  }
}

resource "authentik_service_connection_kubernetes" "in-cluster" {
  name  = "in-cluster"
  local = true
}


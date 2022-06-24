locals {
  dhcp_hosts = yamldecode(file(local.dhcp_hosts_path))["dhcp_hosts"]
}

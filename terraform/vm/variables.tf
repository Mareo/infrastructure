variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "dns_zone" {
  type = string
}

variable "target_node" {
  type = string
}

variable "onboot" {
  type    = bool
  default = true
}

variable "pool" {
  type    = string
  default = ""
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "cores" {
  type    = number
  default = 1
}

variable "memory" {
  type    = number
  default = 1024
}

variable "template" {
  type = string
}

variable "full_clone" {
  type    = bool
  default = false
}

variable "agent" {
  type    = bool
  default = false
}

variable "cloud_init_storage" {
  type    = string
  default = ""
}

variable "sshkeys" {
  type = list(string)
}

variable "network_ip4" {
  type = string
}

variable "network_gw4" {
  type    = string
  default = ""
}

variable "network_driver" {
  type    = string
  default = "virtio"
}

variable "network_bridge" {
  type = string
}

variable "network_macaddr" {
  type    = string
  default = null
}

variable "disk_ssd" {
  type    = bool
  default = true
}

variable "disk_discard" {
  type    = bool
  default = true
}

variable "disk_storage" {
  type = string
}

variable "disk_size" {
  type = string
}

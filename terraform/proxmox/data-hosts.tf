data "proxmox_virtual_environment_hosts" "ada-host" {
  node_name = "ada-host"
}
# data "proxmox_virtual_environment_hosts" "caba-host" {
#   node_name = "caba-host"
# }

data "proxmox_virtual_environment_hosts" "gog-host" {
  node_name = "gog-host"
}

data "proxmox_virtual_environment_hosts" "magog-host" {
  node_name = "magog-host"
}

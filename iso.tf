resource "proxmox_virtual_environment_download_file" "talos_iso" {
  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.iso_node_name
  url          = var.talos_iso_url
  file_name    = var.talos_iso_file_name
  overwrite    = true
}

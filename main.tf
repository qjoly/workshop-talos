
resource "proxmox_virtual_environment_user" "users" {
  for_each = toset(local.user_ids)

  user_id  = "${each.value}@${var.user_realm}"
  comment  = "Terraform-managed account ${each.value}"
  password = lookup(var.user_passwords, each.value, var.default_user_password)
  enabled  = true

  lifecycle {
    ignore_changes = [acl]
  }
}

resource "proxmox_virtual_environment_pool" "user_pools" {
  for_each = toset(local.user_ids)

  pool_id = each.value
  comment = "Sandbox pool for ${each.value}"
}

resource "proxmox_virtual_environment_acl" "user_pool_acl" {
  for_each = toset(local.user_ids)

  path      = "/pool/${each.value}"
  role_id   = local.pool_role_id
  user_id   = proxmox_virtual_environment_user.users[each.value].user_id
  propagate = true

  depends_on = [
    proxmox_virtual_environment_user.users,
    proxmox_virtual_environment_pool.user_pools,
  ]
}

resource "proxmox_virtual_environment_acl" "user_storage_acl" {
  for_each = local.user_storage_acl_entries

  path      = "/storage/${each.value.datastore_id}"
  role_id   = local.pool_role_id
  user_id   = "${each.value.user_id}@${var.user_realm}"
  propagate = false

  depends_on = [
    proxmox_virtual_environment_user.users,
    proxmox_virtual_environment_role.pool_vm_creator,
  ]
}

resource "proxmox_virtual_environment_acl" "user_template_clone_acl" {
  for_each = toset(local.user_ids)

  path      = "/vms/${var.template_clone_vmid}"
  role_id   = local.pool_role_id
  user_id   = "${each.value}@${var.user_realm}"
  propagate = false

  depends_on = [
    proxmox_virtual_environment_user.users,
    proxmox_virtual_environment_role.pool_vm_creator,
  ]
}

resource "proxmox_virtual_environment_acl" "user_sdn_acl" {
  for_each = local.user_sdn_acl_entries

  path      = "/sdn/zones/${each.value.zone}/${each.value.vnet}"
  role_id   = local.pool_role_id
  user_id   = "${each.value.user}@${var.user_realm}"
  propagate = false

  depends_on = [
    proxmox_virtual_environment_user.users,
    proxmox_virtual_environment_role.pool_vm_creator,
  ]
}

locals {
  user_ids = [for i in range(1, var.user_count + 1) : "user-${i}"]

  pool_role_id = coalesce(var.pool_role, proxmox_virtual_environment_role.pool_vm_creator.role_id)

  user_storage_acl_entries = {
    for entry in flatten([
      for user in local.user_ids : [
        for storage_id in var.vm_storage_targets : {
          key          = "${user}:${storage_id}"
          user_id      = user
          datastore_id = storage_id
        }
      ]
      ]) : entry.key => {
      user_id      = entry.user_id
      datastore_id = entry.datastore_id
    }
  }

  user_sdn_acl_entries = {
    for entry in flatten([
      for user in local.user_ids : [
        for target in var.sdn_vnet_targets : {
          key  = "${user}:${target.zone}:${target.vnet}"
          user = user
          zone = target.zone
          vnet = target.vnet
        }
      ]
      ]) : entry.key => {
      user = entry.user
      zone = entry.zone
      vnet = entry.vnet
    }
  }
}

variable "pm_api_url" {
  description = "Proxmox API endpoint, e.g. https://pve.example.com:8006/api2/json"
  type        = string
  default     = "https://192.168.0.200:8006/api2/json"
}

variable "pm_user" {
  description = "Terraform service account, e.g. root@pam or terraform@pve"
  type        = string
  default     = "root@pam"
}

variable "pm_password" {
  description = "Password or API token secret for the Terraform service account"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Skip TLS verification when talking to the Proxmox API"
  type        = bool
  default     = true
}

variable "user_realm" {
  description = "Authentication realm for the managed users (pam, pve, etc.)"
  type        = string
  default     = "pve"
}

variable "user_count" {
  description = "How many numbered users (user-1 .. user-n) to provision"
  type        = number
  default     = 20

  validation {
    condition     = var.user_count >= 1
    error_message = "user_count must be at least 1."
  }
}

variable "default_user_password" {
  description = "Fallback password assigned to users lacking an entry in user_passwords"
  type        = string
  default     = "talos12345!"
  sensitive   = true
}

variable "user_passwords" {
  description = "Optional map of per-user passwords, keyed by user-X"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "pool_role" {
  description = "Optional override role ID applied to pool/storage ACLs. Leave null to use the managed pool-vm-creator role."
  type        = string
  default     = null
}

variable "iso_node_name" {
  description = "Proxmox node that hosts the local datastore where ISOs are stored"
  type        = string
  default     = "pve-atelier-talos"
}

variable "iso_datastore_id" {
  description = "Datastore identifier (e.g. local, local-lvm) where the Talos ISO will be downloaded"
  type        = string
  default     = "local"
}

variable "talos_iso_url" {
  description = "Remote URL of the Talos ISO to download"
  type        = string
  default     = "https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/v1.12.2/metal-amd64.iso"
}

variable "talos_iso_file_name" {
  description = "File name to use when storing the Talos ISO in Proxmox"
  type        = string
  default     = "talos-v1.12.2-metal-amd64.iso"
}

variable "vm_storage_targets" {
  description = "List of storage identifiers (e.g. local, local-lvm) to which users get ACLs for ISO usage and VM disk allocation"
  type        = list(string)
  default     = [
    "local",
    "local-lvm",
  ]
}

variable "template_clone_vmid" {
  description = "VMID of the shared template users are allowed to clone"
  type        = number
  default     = 100
}

variable "sdn_vnet_targets" {
  description = "SDN zone/vnet paths users can attach their NICs to"
  type = list(object({
    zone = string
    vnet = string
  }))
  default = [
    {
      zone = "localnetwork"
      vnet = "vmbr0"
    }
  ]
}

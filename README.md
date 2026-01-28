## Workshop Talos

This repository is a turnkey Terraform stack that prepares a Proxmox VE host for Talos workshops. Running a single `tofu apply` provisions workshop users, isolates them into their own pools, grants tightly-scoped ACLs, and uploads the Talos ISO so every participant starts from the same state. When the workshop ends you can destroy everything and re-apply for a fresh cohort.

### What the automation covers

- Creates numbered users (`user-1`, `user-2`, …) in the realm you choose and resets their passwords from variables.
- Builds matching resource pools so each attendee sees only their sandboxed namespace.
- Downloads the Talos ISO to the local datastore and exposes configured storage targets for VM cloning and disk allocation.
- Grants controlled access to a shared template VM (default VMID `100`) so users can clone it without touching other workloads.
- Assigns `SDN.Use` on specific SDN zone/vnet pairs (for example `localnetwork/vmbr0`) to keep bridge access limited to what the workshop requires.

With these building blocks you get a reproducible, auditable baseline that keeps permissions least-privilege while letting participants create Talos VMs quickly.
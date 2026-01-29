# Create My First Talos Cluster

This guide walks you through building a minimal Talos-based Kubernetes cluster on top of the Proxmox VE environment prepared by this Terraform project. You will provision a single control-plane VM, add a worker, bootstrap Kubernetes, and confirm connectivity with `kubectl`.

## Prerequisites

- Terraform stack already applied so the Talos ISO is uploaded and workshop users/pools exist.
- Template VM (default VMID `100`) containing the Talos install media and ISO.
- `talosctl` `v1.11+` and `kubectl` installed on your workstation.
- Network access from your workstation to the Talos nodes (SSH is not required, but HTTPS/50000 must be reachable).

## 1. Generate machine configurations

Use `talosctl gen secrets` to create a shared secret for the cluster.

Use `talosctl gen config` to create control-plane and worker configurations. Replace the IPs with the ones you plan to assign to your VMs.

```bash
talosctl gen config workshop-cluster https://10.0.0.10:6443 
# Optional: tweak the generated YAML files (controlplane.yaml, worker.yaml)
# to set static routes, registries, or kubelet flags.
```

You will get two more files: `controlplane.yaml` and `worker.yaml`.

## 2. Clone the Talos template

1. In Proxmox VE, select the template VM (VMID `100` by default).
2. Click **Clone**, choose a new VMID (for example `201`), and target your assigned pool/storage.
3. Set the CPU, memory, and disk sizes to match the workshop instructions (typically 2 vCPU / 4 GiB RAM / 20 GiB disk for control planes).
4. Repeat for each additional node (create at least one worker VM such as VMID `211`).

## 3. Apply Talos machine configs

Once the cloned VM boots from the Talos ISO it will display its management IP on the serial console. Use that IP to push the appropriate configuration file.

```bash
# Apply the control-plane config
CONTROL_PLANE_IP=10.0.0.11
talosctl apply-config \
  --insecure \
  --nodes ${CONTROL_PLANE_IP} \
  --file cluster-config/controlplane.yaml

# Apply the worker config
talosctl apply-config \
  --insecure \
  --nodes 10.0.0.21 \
  --file cluster-config/worker.yaml
```

Wait until both nodes reboot and reach the `Ready` state (`talosctl health --endpoints ${CONTROL_PLANE_IP}`).

Configure the talosconfig endpoint to point to your control-plane node:

```bash
talosctl config endpoint ${CONTROL_PLANE_IP}
talosctl config nodes ${CONTROL_PLANE_IP}
```

## 4. Bootstrap the cluster

With at least one control-plane node configured, run the bootstrap command once:

```bash
talosctl bootstrap --endpoints ${CONTROL_PLANE_IP}
```

This initializes etcd, the Kubernetes API server, and the remaining control-plane components.

## 5. Retrieve kubeconfig and verify

```bash
talosctl kubeconfig

export KUBECONFIG=./kubeconfig
kubectl get nodes
```

You should see both the control-plane and worker nodes in `Ready` status. Deploy a sample workload (for example, the [Deployment manifest](kubernetes.md#deployments)) to confirm the cluster works end-to-end.

## Troubleshooting tips

- `talosctl get machineconfig` helps confirm whether the VM picked up the intended YAML.
- Use `talosctl logs kubelet -n ${NODE_IP}` if pods get stuck in `ContainerCreating`.
- Verify the SDN bridge permissions were applied (Terraform `user_sdn_acl` resource) if NIC attachment fails during VM creation.

Once everything looks good you have a baseline Talos cluster. Use snapshots or Terraform state to reset quickly between workshop iterations.

# Next steps

Now that your Talos cluster is up and running, here are some recommended next steps:
- Explore Talos machine configuration options to customize networking, storage, and security settings.
- Deploy more complex Kubernetes workloads using `kubectl` and practice scaling, updating, and monitoring

Is it finished? No, there are still lots of things to improve.

- Secrets are contained in plain text inside the generated machine config files.
- How to customize a Talos node to add features like VPN, monitoring agents, or logging?
- Commands are scoped to a single node at a time. Managing multiple nodes could be tedious.
- Overrides to the base Talos config (for example, adding static routes) require manual YAML edits.

Let's address these pain points in nexts chapters.
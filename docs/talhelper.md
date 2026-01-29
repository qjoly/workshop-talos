---
Title: Use talhpelper to simplify Talos management
---

# Talhelper: your Talos command-line assistant

Talhelper is a command-line tool that simplifies common Talos management tasks, such as generating machine configuration files and applying them to nodes. It abstracts away some of the complexity of using `talosctl` directly.

With it, you can also **separate cluster configuration and secret files**, making it easier to manage and share configurations without exposing sensitive data.

## Installation

Check the documentation at [budimanjojo.github.io](https://budimanjojo.github.io/talhelper/latest/installation/) to install talhelper on your system.

## Usage

Talhelper provides several commands to streamline Talos operations but you still have to resort to `talosctl` for certain tasks like bootstrapping the cluster.

Generate the cluster secret:

```bash
talhelper gensecret > talsecret.yaml
```

Generate machine configuration files for control-plane and worker nodes:

```yaml
# talconfig.yaml
---
clusterName: talos-cluster
talosVersion: v1.12.1
kubernetesVersion: v1.34.1
endpoint: https://192.168.1.101:6443
allowSchedulingOnMasters: true
patches:
  - |-
    - op: replace
      path: /machine/network/kubespan
      value:
        enabled: true 
controlPlane:
  patches:
    - |-
      - op: add
        path: /machine/kubelet/extraArgs
        value:
          feature-gates: ServerSideApply=true
nodes:
  - hostname: cp-1
    ipAddress: 192.168.1.101
    controlPlane: true
    installDisk: /dev/sda
  - hostname: cp-2
    ipAddress: 192.168.1.102
    controlPlane: true
    installDisk: /dev/sda
  - hostname: cp-3
    ipAddress: 192.168.1.103
    controlPlane: true
    installDisk: /dev/sda
  - hostname: worker-1
    ipAddress: 192.168.1.114
    controlPlane: false
    installDisk: /dev/sda
    schematic:
      customization:
        extraKernelArgs:
          - net.ifnames=0
``` 

This example `talconfig.yaml` file defines a Talos cluster with three control-plane nodes and one worker node, along with specific configurations. You can customize it further based on your requirements.
Notice that many parameters can be set using patches, which allows you to modify the generated configuration for a specific node type without changing the base configuration.

Once you're done, you can generate the machine configuration files:

```bash
talhelper genconfig
```

This will create the necessary Talos machine configuration files for each node in the cluster, based on the specifications in `talconfig.yaml`. **Each node will have its own configuration file.**
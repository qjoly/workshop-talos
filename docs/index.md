# Welcome aboard!

Welcome to the Talos Workshop documentation site. Here you'll find all the information you need to set up and run Talos workshops using our Proxmox VE Terraform stack.

## Environment

Before diving in, ensure you have the following prerequisites in place:

- A user with sufficient privileges on the Proxmox VE host to create VMs (clone a template, start/stop VMs)
- `talosctl` installed locally to manage Talos nodes (otherwise, follow the [Talos installation guide](https://docs.siderolabs.com/talos/v1.8/getting-started/talosctl))
- `kubectl` installed locally to interact with the Kubernetes clusters running on Talos nodes (installation instructions can be found [here](https://kubernetes.io/docs/tasks/tools/))

Fell free to ask for help or open issues if you run into any trouble!

Once your environment is ready, head over to the [Getting Started](getting-started.md) guide to begin setting up your Talos workshop.

Ready to launch an actual cluster? Follow the hands-on walkthrough in [Create My First Talos Cluster](create-first-cluster.md).

*For those who don't know Kubernetes yet, I recommend checking out the ["What is Kubernetes?"](kubernetes.md) page to get a basic understanding of the concepts involved.*

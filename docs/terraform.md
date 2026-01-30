# Terraform with Talos and Helm

This guide shows you how to use Terraform to automate the deployment and management of Talos Linux clusters with integrated Helm application deployment.

## Overview

Terraform is an Infrastructure as Code (IaC) tool that allows you to define and provision infrastructure through declarative configuration files. When combined with Talos Linux and Helm, it provides a complete automation solution from cluster creation to application deployment.

## Terraform Providers

### Talos Provider

The Talos provider allows you to manage Talos Linux clusters declaratively.

**Version**: `0.10.1`  
**Provider**: `siderolabs/talos`

**Capabilities:**
- Generate machine configurations
- Bootstrap clusters
- Manage cluster secrets
- Apply configuration patches
- Generate kubeconfig and talosconfig

### Helm Provider

The Helm provider enables automated application deployment to Kubernetes.

**Version**: `3.0.2`  
**Provider**: `hashicorp/helm`

**Features:**
- Deploy Helm charts
- Manage releases
- Configure chart values
- Automatic authentication via kubeconfig

## Project Structure

The workshop's Terraform configuration for Talos is in the `tofu/talos/` directory:

```
tofu/talos/
├── provider.tf          # Talos and Helm providers configuration
├── vars.tf              # Cluster variables (IP, name)
└── main.tf              # Complete cluster lifecycle and Helm deployments
```

## Getting Started

Before deploying a Talos cluster with Terraform, ensure you have:

1. **Talos nodes ready**: VMs or bare metal machines with Talos Linux booted
2. **Network configuration**: IP addresses assigned to your nodes
3. **Terraform installed**: Version 1.10.0 or higher


### Step 1: Provider Configuration

The `provider.tf` file configures both the Talos and Helm providers:

```hcl
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = "https://${var.cp_ip}:6443"
    client_certificate     = base64decode(yamldecode(talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw).users[0].user.client-certificate-data)
    client_key             = base64decode(yamldecode(talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw).users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(yamldecode(talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw).clusters[0].cluster.certificate-authority-data)
  }
}
```

**Key Points:**
- Uses Terraform >= 1.10.0
- Talos provider version 0.10.1
- Helm provider 3.0.2 configured with Talos-generated kubeconfig
- Helm automatically extracts certificates from the kubeconfig

### Step 2: Define Variables

The `vars.tf` file defines cluster parameters:

```hcl
variable "cp_ip" {
  type        = string
  default     = "192.168.0.222"
  description = "Control plane IP address"
}

variable "cluster_name" {
  type        = string
  default     = "my-cluster"
  description = "Name of the Kubernetes cluster"
}
```

### Step 3: Complete Cluster Deployment

The `main.tf` file implements the full cluster lifecycle:

```hcl
# 1. Generate machine secrets
resource "talos_machine_secrets" "talos" {
}

# 2. Generate controller configuration
data "talos_machine_configuration" "controller" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.cp_ip}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.talos.machine_secrets

  config_patches = [
    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = true
      }
    }),
  ]
}

# 3. Generate talosconfig
data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoints            = [var.cp_ip]
}

# 4. Apply configuration to control plane
resource "talos_machine_configuration_apply" "cp_config_apply" {
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller.machine_configuration
  count                       = 1
  node                        = var.cp_ip
}

# 5. Bootstrap the cluster
resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [ talos_machine_configuration_apply.cp_config_apply ]
  client_configuration = talos_machine_secrets.talos.client_configuration
  node                 = var.cp_ip
}

# 6. Generate kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [ talos_machine_bootstrap.bootstrap ]
  client_configuration = talos_machine_secrets.talos.client_configuration
  node                 = var.cp_ip
}

# 7. Deploy application with Helm
resource "helm_release" "nginx" {
  depends_on = [ talos_cluster_kubeconfig.kubeconfig ]
  
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  namespace  = "default"

  set = [
    {
      name  = "service.type"
      value = "NodePort"
    }
  ]
}

# Outputs
output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
```

### Understanding the Workflow

1. **Machine Secrets**: Generate cryptographic secrets for the cluster
2. **Machine Configuration**: Create control plane configuration with scheduling enabled
3. **Talosconfig**: Generate client configuration for `talosctl` commands
4. **Apply Configuration**: Push configuration to the control plane node
5. **Bootstrap**: Initialize the Kubernetes cluster
6. **Kubeconfig**: Generate Kubernetes client configuration
7. **Helm Deployment**: Automatically deploy an NGINX application

### Deploying the Example

```bash
cd tofu/talos/

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the cluster
terraform apply

# Extract kubeconfig
terraform output -raw kubeconfig > ~/.kube/config

# Extract talosconfig
terraform output -raw talosconfig > ~/.talos/config

# Verify the cluster
kubectl get nodes
kubectl get pods -A
```

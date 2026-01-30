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
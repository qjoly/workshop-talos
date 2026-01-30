resource "talos_machine_secrets" "talos" {
}

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

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoints            = [var.cp_ip]
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller.machine_configuration
  count                       = 1
  node                        = var.cp_ip
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [ talos_machine_configuration_apply.cp_config_apply ]
  client_configuration = talos_machine_secrets.talos.client_configuration
  node                 = var.cp_ip
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [ talos_machine_bootstrap.bootstrap ]
  client_configuration = talos_machine_secrets.talos.client_configuration
  node                 = var.cp_ip
}

output "talosconfig" {
  value = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

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
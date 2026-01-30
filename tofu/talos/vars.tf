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
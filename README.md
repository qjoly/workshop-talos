## Workshop Talos

This repository contains Terraform code to deploy many Users and VMs on a Proxmox VE server for a Talos workshop.
I wanted something reproducible and easy to reset between workshops, and Terraform is a great fit for that.

Each user gets a dedicated Proxmox pool, and VMs are created from a Talos ISO image downloaded to the Proxmox server.
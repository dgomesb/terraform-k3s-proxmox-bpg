terraform {

  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.103.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.5"
    }
  }

}

provider "proxmox" {

  endpoint = var.pve_api_url

  #username  = var.pve_user
  #password  = var.pve_password

  api_token = "${var.pve_token_id}=${var.pve_token_secret}"

  insecure = true

  ssh {
    agent       = true
    username    = var.pve_ssh_user
    private_key = file(var.pve_ssh_private_key)
  }

}

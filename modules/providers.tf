terraform {

  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.99"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"
    }

  }

}

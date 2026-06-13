#--------------------#
#  Proxmox provider  #
#--------------------#

variable "pve_api_url" {
  description = "The HTTPS URL of the Proxmox VE API endpoint (e.g., https://proxmox.example.com:8006/api2/json)."
  type        = string
  validation {
    condition     = can(regex("(?i)^http[s]?://.*/api2/json$", var.pve_api_url))
    error_message = "Proxmox API Endpoint Invalid. Check URL - Scheme and Path required."
  }
}

variable "pve_token_id" {
  description = "Proxmox API Token Name."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "pve_token_secret" {
  description = "Proxmox API Token Value."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "pve_ssh_user" {
  description = "SSH connection is required for the proxmox_virtual_environment_file to upload the cloud-init files."
  type        = string
  sensitive   = true
}

variable "pve_ssh_private_key" {
  description = "Private SSH Key. Add the path of the file (e.g. `~/.ssh/private_key`)."
  type        = string
}

#variable "pve_user" {
#  description = "The Proxmox user account used to authenticate against the API (e.g., user@pam)."
#  type        = string
#  ephemeral   = true
#}

#variable "pve_password" {
#  description = "The password for the Proxmox API user."
#  type        = string
#  sensitive   = true
#  ephemeral   = true
#}

#--------------------#
#    Proxmox Node    #
#--------------------#

variable "node_name" {
  description = "The name of the Proxmox node where the virtual machines will be created."
  type        = string
}

variable "datastore_id" {
  description = "The Proxmox datastore ID where VM disks and snippets will be stored."
  type        = string
}

variable "datastore_hdd" {
  description = "Alternative Proxmox datastore ID."
  type        = string
  default     = null
}

#--------------------#
#        VMs         #
#--------------------#

variable "user_name" {
  description = "The default VM user name."
  type        = string
  default     = "ubuntu"
}

variable "user_passwd" {
  description = "The password for the default VM user."
  type        = string
  sensitive   = true
}

variable "ssh_pub_keys" {
  description = "A list of SSH public keys to be injected into the VM via cloud-init."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Virtual machine tag(s)"
  type        = list(string)
  default     = ["k3s"]
}

#--------------------#
#      Network       #
#--------------------#

variable "net_cidr" {
  description = "Network CIDR block (e.g., 192.168.0.0/24)."
  type        = string
}

variable "net_domain" {
  description = "Network domain name assigned to the VM. The first domain on the list is used as the default FQDN"
  type        = list(string)
}

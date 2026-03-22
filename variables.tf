## Proxmox provider ##

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

## Proxmox Node ##

variable "node_name" {
  description = "The name of the Proxmox node where the virtual machines will be created."
  type        = string
}

variable "datastore_id" {
  description = "The Proxmox datastore ID where VM disks and snippets will be stored."
  type        = string
}

## VM ##

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

variable "disk" {
  description = "Disk(s) to be attached to the VM"
  type = list(object({
    datastore_id = optional(string, null) ## on the resource it defaults to var.datastore_id
    import_from  = optional(string, "")   ## not needed when creating an empty disk
    interface    = optional(string, "scsi0")
    size         = optional(number, 40)
    cache        = optional(string, "none")
    iothread     = optional(bool, true)
    backup       = optional(bool, false)
    discard      = optional(string, "on")
    ssd          = optional(bool, true)
    file_format  = optional(string, "qcow2")
    serial       = optional(number, null)
    guest_path   = optional(string, null) ## where to mount the extra disk. Not an official provider variable"
  }))
  default = [{}]
}

variable "tags" {
  description = "Virtual machine tag(s)"
  type        = list(string)
  default     = ["k3s"]
}

## Network ##

variable "net_cidr" {
  description = "Network CIDR block (e.g., 192.168.0.0/24)."
  type        = string
}

variable "net_domain" {
  description = "Network domain name assigned to the VM. The first domain on the list is used as the default FQDN"
  type        = list(string)
}

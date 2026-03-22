## Proxmox Node ##
variable "node_name" {
  description = "Name of the Proxmox node where the VM will be created."
  type        = string
}

variable "datastore_id" {
  description = "Name of the datastore on the selected Proxmox node."
  type        = string
}

## k3s ##
variable "k3s_version" {
  description = "Version of k3s to be installed. If empty, the installation script will automatically select the latest stable version."
  type        = string
  default     = ""
}

## VM ##
variable "count_vm" {
  description = "Number of VM instances (nodes) to be created."
  type        = number
}

variable "vm_id" {
  description = "Unique VM ID. If null, Proxmox will automatically assign an available ID."
  type        = number
  default     = null

  validation {
    condition     = var.vm_id == null || var.vm_id >= 100
    error_message = "vm_id must be a number greater than or equal to 100."
  }
}

variable "hostname" {
  description = "Base hostname assigned to each VM instance."
  type        = string
}

variable "user_name" {
  description = "Username to be created and configured on the VM."
  type        = string
  default     = "ubuntu"
}

variable "user_passwd" {
  description = "Password for the VM user account."
  type        = string
  sensitive   = true
}

variable "ssh_pub_keys" {
  description = "List of SSH public keys to be added to the VM for remote access."
  type        = list(string)
  default     = []
}

variable "cpu" {
  description = "CPU configuration for the VM. Servers require a minimum of 2 vCPUs, and agents require 1 vCPU."
  type = object({
    sockets = optional(number, 1)
    cores   = optional(number, 2)
    type    = optional(string, "host")
  })
  default = {}
}

variable "memory" {
  description = "Amount of RAM (in MB) allocated to each VM. The minimum requirement for the servers is 2 GB."
  type        = number
  default     = 2048
}

variable "bios" {
  description = "VM bios, setting to `ovmf` will automatically create an EFI disk."
  type        = string
  default     = "ovmf"
  validation {
    condition     = contains(["seabios", "ovmf"], var.bios)
    error_message = "Invalid bios setting: ${var.bios}. Valid options: 'seabios' or 'ovmf'."
  }
}

variable "all_nodes" {
  description = "Comma-separated list or string containing all cluster hostnames with their IP addresses."
  type        = string
}

variable "main_server" {
  description = "Hostname or IP address of the main k3s server node."
  type        = string
}

variable "token_id" {
  description = "Proxmox API token ID used for authentication."
  type        = number
}

variable "disk" {
  description = "Main disk configuration. Additional disks can be attached to the VM using this list."
  type = list(object({
    datastore_id = optional(string, null) # Defaults to var.datastore_id in the resource if not specified
    import_from  = optional(string, "")   # Source image to import from; not required when creating an empty disk
    interface    = optional(string, "scsi0")
    size         = optional(number, 40) # Disk size in GB
    cache        = optional(string, "none")
    iothread     = optional(bool, true)
    backup       = optional(bool, false)
    discard      = optional(string, "on")
    ssd          = optional(bool, true)
    file_format  = optional(string, "qcow2")
    serial       = optional(number, null)
    guest_path   = optional(string, null) # Mount point for additional disks (not an official provider argument)
  }))
  default = [{}]
}

variable "dir_mapping" {
  description = <<-EOT
  Shared directory configuration to be mounted inside the VM.

  Attributes:
  - name (string, required):
      Name of the directory mapping in Proxmox.

  - guest_path (optional, string, default: "/mnt/shared"):
      Path inside the guest VM where the directory will be mounted.
  EOT
  type = object({
    name       = string
    guest_path = optional(string, "/mnt/shared")
  })
}

variable "tags" {
  description = "List of tags to be assigned to the VM in Proxmox."
  type        = list(string)
  default     = []
}

## Network ##

variable "vlan_id" {
  description = "The VLAN identifier"
  type        = number
  default     = null
}

variable "net_cidr" {
  description = "Network CIDR block (e.g., 192.168.0.0/24)."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.net_cidr))
    error_message = "The net_cidr value must be a valid IPv4 CIDR block (e.g., 192.168.0.0/24)."
  }
}

variable "ip_addr" {
  description = "Starting IP address offset for the VM. When creating multiple nodes, the IP address will be incremented based on count_vm."
  type        = number
}

variable "gw_ip" {
  description = "Default network gateway IP."
  type        = number
  default     = 1
}

variable "gw_as_dns" {
  description = "Whether to use the default gateway IP as one of the DNS servers"
  type        = bool
  default     = false
}

variable "dns_servers" {
  description = " List of alternative DNS servers (e.g. 1.1.1.1, 8.8.8.8)"
  type        = list(string)
  default     = ["10.0.0.3", "10.0.0.4"]

  validation {
    condition     = var.gw_as_dns || length(var.dns_servers) > 0
    error_message = "The dns_servers list cannot be empty when gw_as_dns is false."
  }
}

variable "net_domain" {
  description = "Network domain name assigned to the VM. The first domain on the list is used as the default FQDN"
  type        = list(string)

  validation {
    condition     = length(var.net_domain) > 0
    error_message = "At least one domain must be specified in the net_domain list."
  }

}



# Control Plane(s) and Worker(s)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.102.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.95.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_file.network_data](https://registry.terraform.io/providers/bpg/proxmox/0.102.0/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_file.user_data](https://registry.terraform.io/providers/bpg/proxmox/0.102.0/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_vm.k3s_node](https://registry.terraform.io/providers/bpg/proxmox/0.102.0/docs/resources/virtual_environment_vm) | resource |
| [random_integer.serial](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_all_nodes"></a> [all\_nodes](#input\_all\_nodes) | Comma-separated list or string containing all cluster hostnames with their IP addresses. | `string` | n/a | yes |
| <a name="input_bios"></a> [bios](#input\_bios) | VM bios, setting to `ovmf` will automatically create an EFI disk. | `string` | `"ovmf"` | no |
| <a name="input_bridge_name"></a> [bridge\_name](#input\_bridge\_name) | The name of the network bridge | `string` | `"vmbr0"` | no |
| <a name="input_count_vm"></a> [count\_vm](#input\_count\_vm) | Number of VM instances (nodes) to be created. | `number` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU configuration for the VM. Servers require a minimum of 2 vCPUs, and agents require 1 vCPU. | <pre>object({<br/>    sockets = optional(number, 1)<br/>    cores   = optional(number, 2)<br/>    type    = optional(string, "host")<br/>  })</pre> | `{}` | no |
| <a name="input_datastore_id"></a> [datastore\_id](#input\_datastore\_id) | Name of the datastore on the selected Proxmox node. | `string` | n/a | yes |
| <a name="input_dir_mapping"></a> [dir\_mapping](#input\_dir\_mapping) | Shared directory configuration to be mounted inside the VM.<br/><br/>Attributes:<br/>- name (string, required):<br/>    Name of the directory mapping in Proxmox.<br/><br/>- guest\_path (optional, string, default: "/mnt/shared"):<br/>    Path inside the guest VM where the directory will be mounted. | <pre>object({<br/>    name       = string<br/>    guest_path = optional(string, "/mnt/shared")<br/>  })</pre> | n/a | yes |
| <a name="input_disk"></a> [disk](#input\_disk) | Main disk configuration. Additional disks can be attached to the VM using this list. | <pre>list(object({<br/>    datastore_id = optional(string, null) # Defaults to var.datastore_id in the resource if not specified<br/>    import_from  = optional(string, "")   # Source image to import from; not required when creating an empty disk<br/>    interface    = optional(string, "scsi0")<br/>    size         = optional(number, 40) # Disk size in GB<br/>    cache        = optional(string, "none")<br/>    iothread     = optional(bool, true)<br/>    backup       = optional(bool, false)<br/>    discard      = optional(string, "on")<br/>    ssd          = optional(bool, true)<br/>    file_format  = optional(string, "qcow2")<br/>    serial       = optional(number, null)<br/>    guest_path   = optional(string, null) # Mount point for additional disks (not an official provider argument)<br/>  }))</pre> | <pre>[<br/>  {}<br/>]</pre> | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of alternative DNS servers (e.g. 1.1.1.1, 8.8.8.8) | `list(string)` | <pre>[<br/>  "10.0.0.3",<br/>  "10.0.0.4"<br/>]</pre> | no |
| <a name="input_gw_as_dns"></a> [gw\_as\_dns](#input\_gw\_as\_dns) | Whether to use the default gateway IP as one of the DNS servers | `bool` | `false` | no |
| <a name="input_gw_ip"></a> [gw\_ip](#input\_gw\_ip) | Default network gateway IP. | `number` | `1` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Base hostname assigned to each VM instance. | `string` | n/a | yes |
| <a name="input_ip_addr"></a> [ip\_addr](#input\_ip\_addr) | Starting IP address offset for the VM. When creating multiple nodes, the IP address will be incremented based on count\_vm. | `number` | n/a | yes |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | Version of k3s to be installed. If empty, the installation script will automatically select the latest stable version. | `string` | `""` | no |
| <a name="input_main_server"></a> [main\_server](#input\_main\_server) | Hostname or IP address of the main k3s server node. | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of RAM (in MB) allocated to each VM. The minimum requirement for the servers is 2 GB. | `number` | `2048` | no |
| <a name="input_net_cidr"></a> [net\_cidr](#input\_net\_cidr) | Network CIDR block (e.g., 192.168.0.0/24). | `string` | n/a | yes |
| <a name="input_net_domain"></a> [net\_domain](#input\_net\_domain) | Network domain name assigned to the VM. The first domain on the list is used as the default FQDN | `list(string)` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | Name of the Proxmox node where the VM will be created. | `string` | n/a | yes |
| <a name="input_ssh_pub_keys"></a> [ssh\_pub\_keys](#input\_ssh\_pub\_keys) | List of SSH public keys to be added to the VM for remote access. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to be assigned to the VM in Proxmox. | `list(string)` | `[]` | no |
| <a name="input_token_id"></a> [token\_id](#input\_token\_id) | Proxmox API token ID used for authentication. | `number` | n/a | yes |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | Username to be created and configured on the VM. | `string` | `"ubuntu"` | no |
| <a name="input_user_passwd"></a> [user\_passwd](#input\_user\_passwd) | Password for the VM user account. | `string` | n/a | yes |
| <a name="input_vlan_id"></a> [vlan\_id](#input\_vlan\_id) | The VLAN identifier | `number` | `null` | no |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | Unique VM ID. If null, Proxmox will automatically assign an available ID. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostname"></a> [hostname](#output\_hostname) | n/a |
| <a name="output_hosts_list"></a> [hosts\_list](#output\_hosts\_list) | List of servers to be created |
| <a name="output_main_server_ip"></a> [main\_server\_ip](#output\_main\_server\_ip) | It will be used to ssh into and get the k3s version |
<!-- END_TF_DOCS -->

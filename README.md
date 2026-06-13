# K3s on Proxmox

> ⚠️ This code was tested on **Proxmox VE v9.1.7**.

This projetct provisions a kubernetes cluster using [K3s](https://k3s.io/) on a Proxmox VE server.
You can either specify the k3s [version](https://github.com/k3s-io/k3s/releases) or allow the script to automatically install the latest stable release.

## Overview

This Terraform configuration:

- Provisions virtual machines on Proxmox VE
- Configures one or more K3s Control Plane node
- Provisions and joins Worker nodes
- Uses Proxmox _Directory Mappings_ to share the cluster join token between nodes

## Requirements

Before applying the Terraform configuration, ensure the following prerequisites are configured in Proxmox VE.

#### 1. Enable `Import` on the Selected Storage

The target storage must allow disk image import.

**Steps:**

1. Navigate to **Datacenter → Storage**
2. Select the desired storage
3. Click **Edit**
4. Under **Content**, enable:
   - `Import`

---

#### 2. Download Ubuntu Image

Download the base image from the official Ubuntu URL and store it in your selected storage.
This prevents the image from being downloaded again every time you run `terraform destroy`, allowing you to reuse the previously stored base image.

---

#### 3. Directory Mapping

A Directory Mapping is required to allow the K3s Control Plane to share the cluster join token with worker nodes. Make sure the `user/token` used by the provider has the following privileges:

- `Mapping.Modify`
- `Mapping.Use`

## Remote Administration

If you have set up the SSH keys correctly and your personal computer can reach one of the servers, you can transfer the `config` file to your machine.

> WARNING

> This will override any existing cluster configuration.

```bash
mkdir "$HOME/.kube"
scp -p ubuntu@hostname:~/.kube/config ~/.kube/config
```

## Acknowledgements

Thanks to the maintainers of the
[terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox)
project for making Proxmox provisioning with Terraform possible.

# Terraform DOCs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.3.5 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.108.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.7.2 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_external"></a> [external](#provider\_external) | 2.4.0 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.109.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_server"></a> [server](#module\_server) | ./modules | n/a |
| <a name="module_worker"></a> [worker](#module\_worker) | ./modules | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [proxmox_download_file.base_image](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/download_file) | resource |
| [proxmox_hardware_mapping_dir.add](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/hardware_mapping_dir) | resource |
| [random_integer.token_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [external_external.k3s_version](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [proxmox_files.base_image](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/data-sources/files) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_datastore_hdd"></a> [datastore\_hdd](#input\_datastore\_hdd) | Alternative Proxmox datastore ID. | `string` | `null` | no |
| <a name="input_datastore_id"></a> [datastore\_id](#input\_datastore\_id) | The Proxmox datastore ID where VM disks and snippets will be stored. | `string` | n/a | yes |
| <a name="input_net_cidr"></a> [net\_cidr](#input\_net\_cidr) | Network CIDR block (e.g., 192.168.0.0/24). | `string` | n/a | yes |
| <a name="input_net_domain"></a> [net\_domain](#input\_net\_domain) | Network domain name assigned to the VM. The first domain on the list is used as the default FQDN | `list(string)` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | The name of the Proxmox node where the virtual machines will be created. | `string` | n/a | yes |
| <a name="input_pve_api_url"></a> [pve\_api\_url](#input\_pve\_api\_url) | The HTTPS URL of the Proxmox VE API endpoint (e.g., https://proxmox.example.com:8006/api2/json). | `string` | n/a | yes |
| <a name="input_pve_ssh_private_key"></a> [pve\_ssh\_private\_key](#input\_pve\_ssh\_private\_key) | Private SSH Key. Add the path of the file (e.g. `~/.ssh/private_key`). | `string` | n/a | yes |
| <a name="input_pve_ssh_user"></a> [pve\_ssh\_user](#input\_pve\_ssh\_user) | SSH connection is required for the proxmox\_virtual\_environment\_file to upload the cloud-init files. | `string` | n/a | yes |
| <a name="input_pve_token_id"></a> [pve\_token\_id](#input\_pve\_token\_id) | Proxmox API Token Name. | `string` | n/a | yes |
| <a name="input_pve_token_secret"></a> [pve\_token\_secret](#input\_pve\_token\_secret) | Proxmox API Token Value. | `string` | n/a | yes |
| <a name="input_ssh_pub_keys"></a> [ssh\_pub\_keys](#input\_ssh\_pub\_keys) | A list of SSH public keys to be injected into the VM via cloud-init. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Virtual machine tag(s) | `list(string)` | <pre>[<br/>  "k3s"<br/>]</pre> | no |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | The default VM user name. | `string` | `"ubuntu"` | no |
| <a name="input_user_passwd"></a> [user\_passwd](#input\_user\_passwd) | The password for the default VM user. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_all_nodes"></a> [all\_nodes](#output\_all\_nodes) | Shows what will be appended to /etc/hosts on each VM |
| <a name="output_k3s_version"></a> [k3s\_version](#output\_k3s\_version) | k3s version to be installed on the nodes |
<!-- END_TF_DOCS -->

locals {

  count_servers = 2
  count_workers = 3

  k3s_version = "1.35.3+k3s1" ## https://github.com/k3s-io/k3s/releases

  main_server = format("%s01.%s", module.server.hostname, var.net_domain[0])

  all_nodes = join("\n",
    module.server.hosts_list,
    module.worker.hosts_list
  )

  base_image_file = "noble-server-cloudimg-amd64.qcow2"

  search_base_image = [
    for f in data.proxmox_files.base_image.files : f
    if f.file_name == local.base_image_file
  ]

}

resource "random_integer" "token_id" {
  max = 99999
  min = 10000
}

resource "proxmox_hardware_mapping_dir" "add" {
  comment = "Where to save the k3s token"
  name    = "k3s"
  map = [{
    node = var.node_name
    path = "/var/tmp" ## this path must exist on the node
  }]
}

data "proxmox_files" "base_image" {
  node_name    = var.node_name
  datastore_id = var.datastore_id
  content_type = "import"
}

resource "proxmox_download_file" "base_image" {

  count = length(local.search_base_image) == 0 ? 1 : 0

  node_name    = var.node_name
  datastore_id = var.datastore_id
  content_type = "import"

  ## Ubuntu minimal does not support uefi
  #url       = "https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img"
  #file_name = local.base_image_file

  url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name = local.base_image_file

}

module "server" {

  source = "./modules"

  count_vm    = local.count_servers < 1 ? 1 : local.count_servers
  k3s_version = local.k3s_version

  ## Proxmox
  node_name    = var.node_name
  datastore_id = var.datastore_id

  ## VM
  vm_id        = 241
  hostname     = "k3s-server"
  user_name    = var.user_name
  user_passwd  = var.user_passwd
  ssh_pub_keys = var.ssh_pub_keys
  all_nodes    = local.all_nodes
  token_id     = random_integer.token_id.result
  main_server  = local.main_server

  disk = [{
    import_from = length(local.search_base_image) > 0 ? local.search_base_image[0].id : proxmox_download_file.base_image[0].id
  }]

  ## Network
  ip_addr     = 241
  net_cidr    = var.net_cidr
  net_domain  = var.net_domain
  dir_mapping = { name = proxmox_hardware_mapping_dir.add.name }

  tags = concat(var.tags, ["cp"])

}

module "worker" {

  source = "./modules"

  count_vm    = local.count_workers
  k3s_version = local.k3s_version

  ## Proxmox
  node_name    = var.node_name
  datastore_id = var.datastore_id

  ## VM
  vm_id        = 245
  hostname     = "k3s-worker"
  user_name    = var.user_name
  user_passwd  = var.user_passwd
  ssh_pub_keys = var.ssh_pub_keys
  all_nodes    = local.all_nodes
  token_id     = random_integer.token_id.result
  main_server  = local.main_server
  memory       = 1536
  disk = [{
    import_from = length(local.search_base_image) > 0 ? local.search_base_image[0].id : proxmox_download_file.base_image[0].id
  }]

  ## Network
  ip_addr     = 245
  net_cidr    = var.net_cidr
  net_domain  = var.net_domain
  dir_mapping = { name = proxmox_hardware_mapping_dir.add.name }

  tags = concat(var.tags, ["worker"])

}

data "external" "k3s_version" {

  count = local.k3s_version == "" ? 1 : 0

  depends_on = [module.server[0]]

  program = ["bash", "-c",
    <<-EOT
      eval "$(jq -r '@sh "USER=\(.user) HOST=\(.host)"')"
      RUN_SSH="ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes"
      for i in {1..15}; do $RUN_SSH "$USER@$HOST" 'systemctl is-active --quiet k3s' && break; sleep 3; done
      VERSION=$($RUN_SSH "$USER@$HOST" "k3s --version 2>/dev/null | head -n1 | awk '{print \$3, \$4}'")
      [ -z "$VERSION"] && VERSION="timed out"
      jq -n --arg version "$VERSION" '{"version":$version}'
    EOT
  ]

  query = {
    user = var.user_name
    host = module.server.main_server_ip
  }

}

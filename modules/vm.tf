locals {
  hosts_list = [
    for i in range(var.count_vm) : join("  ", [
      cidrhost(var.net_cidr, i + var.ip_addr),
      format("%s%02d", var.hostname, i + 1),
      join("  ", [
        for d in var.net_domain : format("%s%02d.%s", var.hostname, i + 1, d)
      ])
    ])
  ]

  alphabet = split("", "abcdefghijklmnopqrstuvwxyz")
  extra_disks = [
    for idx, d in var.disk : {
      device_letter = local.alphabet[idx]
      guest_path    = d.guest_path
    }
    if idx > 0 && try(d.guest_path, null) != null
  ]

}

resource "random_integer" "serial" {

  count = var.count_vm

  max = 9999999
  min = 1000000

}

resource "proxmox_virtual_environment_file" "user_data" {

  count = var.count_vm

  node_name    = var.node_name
  datastore_id = var.datastore_id
  content_type = "snippets"

  source_raw {
    file_name = format("userdata-%s%02d.yaml", var.hostname, count.index + 1)
    data = templatefile("${path.module}/configs/userdata.tftpl", {
      hostname     = format("%s%02d", var.hostname, count.index + 1)
      net_domain   = var.net_domain
      username     = var.user_name
      password     = var.user_passwd
      ssh_pub_keys = var.ssh_pub_keys
      dir_mapping  = var.dir_mapping
      all_nodes    = indent(6, var.all_nodes)
      extra_disks  = local.extra_disks
      service      = indent(6, file("${path.module}/configs/setupk3s.service"))
      setupk3s = indent(6, templatefile("${path.module}/configs/setupk3s", {
        k3s_version = var.k3s_version
        username    = var.user_name
        main_server = var.main_server
        dir_mapping = var.dir_mapping
        token_id    = var.token_id
      }))
    })
  }

}

resource "proxmox_virtual_environment_file" "network_data" {

  count = var.count_vm

  node_name    = var.node_name
  datastore_id = var.datastore_id
  content_type = "snippets"

  source_raw {
    file_name = format("network-%s%02d.yaml", var.hostname, count.index + 1)
    data = templatefile("${path.module}/configs/network.tftpl", {
      address     = "${cidrhost(var.net_cidr, var.ip_addr + count.index)}/${split("/", var.net_cidr)[1]}"
      igw         = cidrhost(var.net_cidr, var.gw_ip)
      net_domain  = var.net_domain
      dns_servers = concat(var.gw_as_dns == false ? [] : [cidrhost(var.net_cidr, var.gw_ip)], var.dns_servers)
    })
  }

}

resource "proxmox_virtual_environment_vm" "k3s_node" {

  count = var.count_vm

  node_name = var.node_name
  vm_id     = var.vm_id != null ? var.vm_id + count.index : null

  name        = format("%s%02d", var.hostname, count.index + 1)
  description = "Managed by Terraform. K3s node."
  started     = true
  on_boot     = false

  machine = "q35,viommu=virtio"

  agent { enabled = true }

  operating_system { type = "l26" }

  vga {
    type   = "qxl"
    memory = 8
  }

  bios = var.bios

  dynamic "efi_disk" {
    for_each = var.bios == "ovmf" ? [1] : []
    content {
      datastore_id      = var.datastore_id
      file_format       = "qcow2"
      type              = "4m"
      pre_enrolled_keys = false
    }
  }

  scsi_hardware = "virtio-scsi-single"

  dynamic "disk" {
    for_each = var.disk
    content {
      datastore_id = coalesce(disk.value.datastore_id, var.datastore_id)
      import_from  = disk.value.import_from
      interface    = "scsi${disk.key}"
      size         = disk.value.size
      cache        = disk.value.cache
      iothread     = disk.value.iothread
      backup       = disk.value.backup
      discard      = disk.value.discard
      ssd          = disk.value.ssd
      file_format  = disk.value.file_format
      serial       = random_integer.serial[count.index].result + disk.key
      #serial       = (var.vm_id + count.index) * 5678 + disk.key
    }
  }

  cpu {
    sockets = var.cpu.sockets
    cores   = var.cpu.cores
    type    = var.cpu.type
    limit   = var.cpu.sockets * var.cpu.cores
  }

  memory {
    dedicated = var.memory
    floating  = var.memory # set equal to dedicated to enable ballooning
  }

  virtiofs {
    mapping   = var.dir_mapping.name
    cache     = "auto"
    direct_io = true
  }

  network_device {
    bridge   = var.bridge_name
    model    = "virtio"
    firewall = true
    vlan_id  = var.vlan_id
  }

  serial_device { device = "socket" }

  rng { source = "/dev/random" }

  initialization {
    datastore_id         = var.datastore_id
    user_data_file_id    = proxmox_virtual_environment_file.user_data[count.index].id
    network_data_file_id = proxmox_virtual_environment_file.network_data[count.index].id
  }

  tags = var.tags

}

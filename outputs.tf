output "all_nodes" {
  description = "Shows what will be appended to /etc/hosts on each VM"
  value       = local.all_nodes
}

output "k3s_version" {
  description = "k3s version to be installed on the nodes"
  value       = local.k3s_version != "" ? local.k3s_version : data.external.k3s_version[0].result.version
}

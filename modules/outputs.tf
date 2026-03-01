output "hosts_list" {
  description = "List of servers to be created"
  value       = local.hosts_list
}

output "hostname" {
  value = var.hostname
}

output "main_server_ip" {
  description = "It will be used to ssh into and get the k3s version"
  value       = cidrhost(var.net_cidr, var.ip_addr)
}
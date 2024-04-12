# The IP address of the created server is outputted here
output "primary_ipv4_addresses" {
  value = { for key, ip in hcloud_primary_ip.primary_ipv4 : key => ip.ip_address }
}

# The name of the server is outputted here
output "names" {
  value = { for key, server in hcloud_server.server : key => server.name }
}

# The domain of the server is outputted here
output "domain" {
  value = var.domain
}

# The ID of the server is outputted here
output "ids" {
  value = { for key, server in hcloud_server.server : key => server.id }
}
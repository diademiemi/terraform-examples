# The IP address of the created server is outputted here
output "primary_ipv4_address" {
  value = hcloud_primary_ip.primary_ipv4.ip_address
}

# The name of the server is outputted here
output "name" {
  value = hcloud_server.server.name
}

# The domain of the server is outputted here
output "domain" {
  value = var.domain
}

# The ID of the server is outputted here
output "id" {
  value = hcloud_server.server.id
}
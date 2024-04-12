# The IP address of the created servers are outputted here
output "primary_ipv4_addresses" {
  value = { for key, server in module.server_module : key => server.primary_ipv4_address }
}

# The names of the servers are outputted here
output "names" {
  value = { for key, server in module.server_module : key => server.name }
}

# The IDs of the servers are outputted here
output "ids" {
  value = { for key, server in module.server_module : key => server.id }
}

# Create a IPv4 primary IP the server can use
resource "hcloud_primary_ip" "primary_ipv4" {
  # Loop over the servers and create a primary IP for each
  for_each = { for vm in var.servers : vm.name => vm}

  name          = "primary_ip_${each.value.name}-${var.suffix}"
  datacenter    = var.datacenter
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
}

# A "data" block is used to fetch data from the provider. In this case, we are fetching the list of existing SSH keys from the Hetzner Cloud provider.
# We don't give any arguments, since we just want all the existing SSH keys.
data "hcloud_ssh_keys" "existing_ssh_keys" {
}

# Create the server
resource "hcloud_server" "server" {

  # Wait for the primary IP and SSH keys to be created
  depends_on = [
    hcloud_primary_ip.primary_ipv4,
    data.hcloud_ssh_keys.existing_ssh_keys
  ]

  for_each = { for vm in var.servers : vm.name => vm}

  # Name the server based on the domain, this time with a string suffix
  # IF domain is defined and not an empty string, name it as ${var.name}-${var.suffix}.${var.domain}
  # ELSE name it as ${var.name}-${var.suffix}
  name        = var.domain != null && var.domain != "" ? "${each.value.name}-${var.suffix}.${var.domain}" : "${each.value.name}-${var.suffix}"
  # Get the type of server to create from the list
  server_type = each.value.type

  image       = var.image
  datacenter  = var.datacenter

  # Pass all the existing SSH keys to the server
  # I wrap this in a try statement to cleanly default to an empty list if there are no existing SSH keys
  ssh_keys = try(data.hcloud_ssh_keys.existing_ssh_keys.ssh_keys.*.name, [])

  public_net {
    ipv4_enabled = true
    # Get the primary IP for this server
    ipv4 = hcloud_primary_ip.primary_ipv4[each.value.name].id
  }

}

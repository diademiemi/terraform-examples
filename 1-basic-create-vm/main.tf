# Create a IPv4 primary IP the server can use
resource "hcloud_primary_ip" "primary_ipv4" {
  name          = "primary_ip_${var.name}"
  datacenter    = var.datacenter
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
}

# Create the SSH keys
resource "hcloud_ssh_key" "new_ssh_keys" {
  for_each   = var.new_ssh_keys
  # Name the key based on the server
  # IF domain is defined and not an empty string, name it as ${each.key}-${var.name}.${var.domain}
  # ELSE name it as ${each.key}-${var.name}
  name = var.domain != null && var.domain != "" ? "${each.key}-${var.name}.${var.domain}" : "${each.key}-${var.name}"
  public_key = each.value
}

# Create the server
resource "hcloud_server" "server" {

  # Wait for the primary IP and SSH keys to be created
  depends_on = [
    hcloud_primary_ip.primary_ipv4,
    hcloud_ssh_key.new_ssh_keys
  ]

  # Name the server based on the domain
  # IF domain is defined and not an empty string, name it as ${var.name}.${var.domain}
  # ELSE name it as ${var.name}
  name        = var.domain != null && var.domain != "" ? "${var.name}.${var.domain}" : var.name
  server_type = var.type
  image       = var.image
  datacenter  = var.datacenter

  # Loop over the created SSH keys and extract the ID
  ssh_keys = [for k, v in hcloud_ssh_key.new_ssh_keys : hcloud_ssh_key.new_ssh_keys[k].id]

  # Add public IPs
  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.primary_ipv4.id
  }

}

# Create a IPv4 primary IP the server can use
resource "hcloud_primary_ip" "primary_ipv4" {
  name          = "primary_ip_${var.name}"
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

  # Name the server based on the domain
  # IF domain is defined and not an empty string, name it as ${var.name}.${var.domain}
  # ELSE name it as ${var.name}
  name        = var.domain != null && var.domain != "" ? "${var.name}.${var.domain}" : var.name
  server_type = var.type
  image       = var.image
  datacenter  = var.datacenter

  # Pass all the existing SSH keys to the server
  # I wrap this in a try statement to cleanly default to an empty list if there are no existing SSH keys
  ssh_keys = try(data.hcloud_ssh_keys.existing_ssh_keys.ssh_keys.*.name, [])

  # Add public IPs
  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.primary_ipv4.id
  }

}

resource "ansible_host" "default" {
  name   = coalesce(var.ansible_name, var.name)
  groups = var.ansible_groups

  variables = {
    ansible_host     = coalesce(var.ansible_host, hcloud_primary_ip.primary_ipv4.ip_address, var.name)
    ansible_user     = coalesce(var.ansible_user, "root")
    ansible_ssh_pass = coalesce(var.ansible_ssh_pass, "root")
    ansible_ssh_private_key_file = try(var.ansible_ssh_private_key_file, "")
  }
}
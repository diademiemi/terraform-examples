# Create the SSH keys
resource "hcloud_ssh_key" "new_ssh_keys" {
  for_each   = var.new_ssh_keys
  name       = each.key
  public_key = each.value
}

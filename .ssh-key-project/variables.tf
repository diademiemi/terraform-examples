variable "hcloud_api_token" {
  description = "API token for Hetzner Cloud"
  type        = string
  sensitive = true
}

variable "new_ssh_keys" {
  description = "Map of new SSH keys to create"
  type        = map(string)
  default     = {}
  nullable = false
  // Example:
  // new_ssh_keys = {
  //   "my-key" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7z..."
  // }
}

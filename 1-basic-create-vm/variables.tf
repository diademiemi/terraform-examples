variable "hcloud_api_token" {
  description = "API token for Hetzner Cloud"
  type        = string
  sensitive = true
}

variable "name" {
  description = "Name of the server"
  type        = string
}

variable "domain" {
  type    = string
  default = null
  nullable = true
}

variable "type" {
  description = "Type of server to create"
  type        = string
  default     = "cx11"
  nullable = false
}

variable "image" {
  description = "OS image to use for the server"
  type        = string
  default     = "ubuntu-22.04"
  nullable = false
}

variable "datacenter" {
  description = "Datacenter for the server"
  type        = string
  default     = "nbg1-dc3"
  nullable = false
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

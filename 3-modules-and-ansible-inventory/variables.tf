variable "hcloud_api_token" {
  description = "API token for Hetzner Cloud"
  type        = string
  sensitive = true
}

variable "suffix" {
  description = "Suffix to append to the server name"
  type        = string
}

variable "servers" {
  description = "List of servers to create"
  type        = list(object({
    name = string
    type = optional(string)
    image = optional(string)
    datacenter = optional(string)
    domain = optional(string)

    ansible_name = optional(string)
    ansible_host = optional(string)
    ansible_user = optional(string)
    ansible_ssh_pass = optional(string)
    ansible_groups = optional(list(string))
    ansible_ssh_private_key_file = optional(string)
  }))
  default     = []
  nullable = false
}

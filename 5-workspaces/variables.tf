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
  }))
  default     = []
  nullable = false
}

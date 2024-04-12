variable "hcloud_api_token" {
  description = "API token for Hetzner Cloud"
  type        = string
  sensitive = true
}

variable "suffix" {
  description = "Suffix to append to the server name"
  type        = string
}

variable "domain" {
  type    = string
  default = null
  nullable = true
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

variable "servers" {
  description = "List of servers to create"
  type        = list(object({
    name = string
    type = string
  }))
  default     = []
  nullable = false
}
variable "name" {
  description = "Name of the server"
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

variable "type" {
  description = "Type of server to create"
  type        = string
  default     = "cx11"
  nullable = false
}

variable "datacenter" {
  description = "Datacenter for the server"
  type        = string
  default     = "nbg1-dc3"
  nullable = false
}

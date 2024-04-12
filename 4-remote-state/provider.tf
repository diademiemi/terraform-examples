# Terraform config block
terraform {
  # Which providers we use
  required_providers {
    # Hetzner Cloud provider
    hcloud = {
      # Source string
      source = "hetznercloud/hcloud"
      # Version constraints. Anything above 1.0 and below 2.0 will do here.
      version = "~> 1.0"
    }
    # The module defines the Ansible provider and it doesn't need any setup, so we don't need to define it here.
  }
  backend "http" {
  }
}

provider "hcloud" {
  token = var.hcloud_api_token
}

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
    ansible = {
      version = "~> 1.0.0"
      source  = "ansible/ansible"
    }
  }
}

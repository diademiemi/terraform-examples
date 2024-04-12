# [3: Modules and Ansible Inventory](#3-modules-and-ansible-inventory)

In this example, we use a module to create two VMs, the same as in the previous example, now with a module.

# Table of Contents
- [3: Modules and Ansible Inventory](#3-modules-and-ansible-inventory)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Activity 1: Create VMs with example.tfvars](#activity-1-create-vms-with-exampletfvars)
  - [Install Terraform requirements](#install-terraform-requirements)
  - [Launch](#launch)
  - [Using Ansible](#using-ansible)
  - [Destroy](#destroy)
  - [Seeing the Ansible inventory](#seeing-the-ansible-inventory)
- [Code explanation](#code-explanation)
  - [Files](#files)
  - [Why do I use a `try` statement everywhere?](#why-do-i-use-a-try-statement-everywhere)
  - [Module sources](#module-sources)
  - [How do we get the IP from the module?](#how-do-we-get-the-ip-from-the-module)


# [Prerequisites](#prerequisites)
- Terraform installed
- Hetzner API token

# [Activity 1: Create VMs with example.tfvars](#activity-1-create-vms-with-exampletfvars)

## [Install Terraform requirements](#install-terraform-requirements)
We need to first fetch the providers and module, even if it's a local path (like in this case). Run the following command:

```bash
terraform init
```

## [Launch](#launch)
Let's use the given `example.tfvars` file to create a VM.

Navigate to this directory and run:

```bash
# Check what will be created
terraform plan -var-file tfvars/example.tfvars

# Create the VM
terraform apply -var-file tfvars/example.tfvars
```

It will prompt for the Hetzner API token and a suffix for the servers, please use your initials (e.g. `jk`). This is to prevent duplicates in the lab. 
## [Using Ansible](#using-ansible)
In this module we also created an `ansible_host` resource. This can be read by the `cloud.terraform.terraform_provider` inventory provider (part of the `cloud.terraform` collection).

With this, we can automatically add the servers to a dynamic Ansible inventory.

For this example, let's move to the `ansible` directory located in this example and run the following commands:

Install the collection:
```bash
# Install the Ansible requirements
ansible-galaxy install -r requirements.yml
```

List the inventory (It is set as default in `ansible.cfg`):
```bash
# Show the inventory as a graph
ansible-inventory --graph
```
You should now see the two servers listed.

Let's run an example playbook:
```bash
# Install Nginx on the servers
ansible-playbook playbooks/webserver.yml
```

You should now be able to go to the outputted IP addresses (`terraform output primary_ipv4_addresses`) and see the default Nginx page.

###### Connecting to these VMs requires the SSH key uploaded to the environment to be set as a key Ansible can use. You can add `-e ansible_ssh_private_key_file=<path to key>` to the command to specify the key.

## [Destroy](#destroy)
To destroy the VM, run (in the Terraform directory, not Ansible directory):

```bash
terraform destroy -var-file tfvars/example.tfvars
```

Once again it'll prompt for the Hetzner API token and the name of the server. It will destroy everything in the Terraform state, so the suffixes of the servers don't really matter anymore.

## [Seeing the Ansible inventory](#seeing-the-ansible-inventory)
After destroying the VMs, the Ansible inventory will now be empty. You can see this by running the `ansible-inventory --graph` command again.

# [Code explanation](#code-explanation)

## [Files](#files)

File | Purpose | Notes
--- | --- | ---
[main.tf](main.tf) | Main Terraform file | Creates the server
[outputs.tf](outputs.tf) | Outputs | Outputs the IP address, name and domain of the servers
[variables.tf](variables.tf) | Variables | Defines the variables used in the main file
[provider.tf](provider.tf) | Provider | Configures the Hetzner Cloud provider
[example.tfvars](tfvars/example.tfvars) | Example tfvars | Example tfvars file which fills in the required variables
[server_module/main.tf](server_module/main.tf) | Module main file | Creates the server
[server_module/variables.tf](server_module/variables.tf) | Module variables | Defines the variables used in the module
[server_module/outputs.tf](server_module/outputs.tf) | Module outputs | Outputs the IP address, name and domain of the server
[server_module/provider.tf](server_module/provider.tf) | Module provider | Configures the Hetzner Cloud provider for the module
[ansible/requirements.yml](ansible/requirements.yml) | Ansible requirements | Defines the requirements for the Ansible collection
[ansible/inventories/terraform/terraform.yml](ansible/inventories/terraform/terraform.yml) | Ansible inventory | Defines the dynamic inventory for the Terraform provider
[ansible/playbooks/webserver.yml](ansible/playbooks/webserver.yml) | Ansible playbook | Example playbook to install a webserver
[ansible/ansible.cfg](ansible/ansible.cfg) | Ansible config | Configures Ansible to use the dynamic inventory

## [Why do I use a `try` statement everywhere?](#why-do-i-use-a-try-statement-everywhere)
```hcl
    image = try(each.value.image, null)
    type = try(each.value.type, null)
    datacenter = try(each.value.datacenter, null)
```
I use a `try` statement here to catch any errors that might occur if the value doesn't exist. The second argument is the default value if the value doesn't exist.

```hcl
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
```

I default to `null` since the module already defines its own defaults. Every optional variable in the module has `nullable = false`. What this does is fall back to the default variable if the value is given as `null` (otherwise it'll just try to use `null` as value). This avoids unexpected errors and makes sure the code always has a default to fall back on.

## [Module sources](#module-sources)
```hcl
module "server_module" {
    source = "./server_module"
}
```
Here I use a local path to the module. This is useful for development and testing. In a real-world scenario, you would use a Git repository or a Terraform registry.

For example, to use my module from the Terraform registry, I would use the following:

```hcl
module "server_module" {
  source     = "diademiemi/vm/hetzner"
  version    = "2.0.0"
}
```
###### Warning: This is a different module than we're using here in the example!

To get one from a GitLab Terraform registry, use the following:

```hcl
module "server_module" {
  source = "gitlab.example.com/group/terraform-hetzner-vm/hetzner"
  version = "1.0.0"
}
```

To get one from a Git repository, use the following:

```hcl
module "server_module" {
  source = "git::https://example.com/user/terraform-hetzner-vm.git"
}
```

## [How do we get the IP from the module?](#how-do-we-get-the-ip-from-the-module)
The module defines the IP (among other things) as an output. We can then access the module output from the `outputs.tf` in the project.

Module outputs:
```hcl
# The IP address of the created server is outputted here
output "primary_ipv4_address" {
  value = hcloud_primary_ip.primary_ipv4.ip_address
}
```

This is then accessed in the main `outputs.tf` file:
```hcl
# The IP address of the created servers are outputted here
output "primary_ipv4_addresses" {
  value = { for key, server in module.server_module : key => server.primary_ipv4_address }
}
```

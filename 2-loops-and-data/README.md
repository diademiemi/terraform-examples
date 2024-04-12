# [2: Loops and Data](#2-loops-and-data)

In this example, we'll create multiple VMs with Terraform and fetch existing SSH keys from the Hetzner Cloud API.

# Table of Contents
- [2: Loops and Data](#2-loops-and-data)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Activity 1: Create VMs with example.tfvars](#activity-1-create-vms-with-exampletfvars)
  - [Install Terraform requirements](#install-terraform-requirements)
  - [Launch](#launch)
  - [Logging in](#logging-in)
  - [Destroy](#destroy)
- [Code explanation](#code-explanation)
  - [Files](#files)
  - [Why is the `for_each` so complicated?](#why-is-the-for_each-so-complicated)
  - [`data` Block](#data-block)
  - [Outputs](#outputs)

# [Prerequisites](#prerequisites)
- Terraform installed
- Hetzner API token

# [Activity 1: Create VMs with example.tfvars](#activity-1-create-vms-with-example-tfvars)

## [Install Terraform requirements](#install-terraform-requirements)
We need to first fetch the providers. Run the following command:

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
In this example, we defined a data source for the existing SSH keys. Since you all already gave me your SSH pubkeys, this data source automatically finds the keys and adds them to the VM.

## [Logging in](#logging-in)
We'll need to get the IP of the VM. We've defined this as an output in `outputs.tf`. We can get this with the following command:

```bash
terraform output primary_ipv4_addresses
```

Now, we can log in with the following command:

```bash
ssh root@<IP>
```
###### Note: Replace `<IP>` with the IP address you got from the output.


## [Destroy](#destroy)
To destroy the VM, run:

```bash
terraform destroy -var-file tfvars/example.tfvars
```

Once again it'll prompt for the Hetzner API token and the name of the server. It will destroy everything in the Terraform state, so the suffixes of the servers don't really matter anymore.

# [Code explanation](#code-explanation)

## [Files](#files)

File | Purpose | Notes
--- | --- | ---
[main.tf](main.tf) | Main Terraform file | Creates the server
[outputs.tf](outputs.tf) | Outputs | Outputs the IP address, name and domain of the servers
[variables.tf](variables.tf) | Variables | Defines the variables used in the main file
[provider.tf](provider.tf) | Provider | Configures the Hetzner Cloud provider
[example.tfvars](tfvars/example.tfvars) | Example tfvars | Example tfvars file which fills in the required variables

## [Why is the `for_each` so complicated?](#why-is-the-for_each-so-complicated)
```
resource "hcloud_server" "server" {
...
  for_each = { for vm in var.servers : vm.name => vm}
...
}
```
Terraform expects a map for `for_each`. We're converting the list of servers to a map with the server name as the key. This is to make the variables file more readable and easier to write (just a list of objects instead of a map with potentially duplicate data).

From this point onward, the list gets converted into a map. For example:
```hcl
servers = [
  {
    name = "server1"
    type = "cx21"
  },
  {
    name = "server2"
    type = "cx21"
  }
]
```
Becomes:
```hcl
{
  "server1" = {
    name = "server1"
    type = "cx21"
  },
  "server2" = {
    name = "server2"
    type = "cx21"
  }
}
```

This way we can reference the name with either `each.value.name` or `each.key`. The type can be referenced with `each.value.type`.

## [`data` Block](#data-block)
```hcl
data "hcloud_ssh_keys" "existing_ssh_keys" {
}
```
The `data` block is used to fetch data from an external source. In this case, we're fetching the SSH keys from the Hetzner Cloud API.

## [Outputs](#outputs)
```hcl
output "primary_ipv4_addresses" {
  value = { for key, ip in hcloud_primary_ip.primary_ipv4 : key => ip.ip_address }
}
```
This output is a generated map of the server name and the primary IPv4 address. This shows for example:
```hcl
primary_ipv4_addresses = {
  "web-1" = "xxx.xxx.xxx.xxx"
  "web-2" = "yyy.yyy.yyy.yyy"
}
```

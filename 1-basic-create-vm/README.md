# 1: [Basic VM creation](#1-basic-vm-creation)

In this example, just a basic Hetzner VM is created.

# Table of Contents
- [1: Basic VM creation](#1-basic-vm-creation)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Activity 1: Create a VM with example.tfvars](#activity-1-create-a-vm-with-exampletfvars)
  - [Install Terraform requirements](#install-terraform-requirements)
  - [Launch](#launch)
  - [Destroy](#destroy)
- [Activity 2: Create a VM with our own tfvars](#activity-2-create-a-vm-with-our-own-tfvars)
  - [Create custom tfvars](#create-custom-tfvars)
  - [Launch](#launch-1)
  - [Logging in](#logging-in)
  - [Destroy](#destroy-1)
- [Code explanation](#code-explanation)
  - [Files](#files)
  - [Why is the `name` field in the server so complicated?](#why-is-the-name-field-in-the-server-so-complicated)
  - [What is `depends_on`?](#what-is-depends_on)
  - [Why is the `ssh_keys` field in the server so complicated?](#why-is-the-ssh_keys-field-in-the-server-so-complicated)


# [Prerequisites](#prerequisites)
- Terraform installed
- Hetzner API token

# [Activity 1: Create a VM with example.tfvars](#activity-1-create-a-vm-with-exampletfvars)

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

It will prompt for the Hetzner API token and a name for the server. Any variables that do not have a default and are not given (either in `-var` or in a `.tfvars` file) will be prompted for.

After it is created, I will have gotten an email with the root password and login information.

In the next activity, let's add our own `tfvars` file so that we can add a custom SSH key and log in automatically without needing the root password.

## [Destroy](#destroy)
To destroy the VM, run:

```bash
terraform destroy -var-file tfvars/example.tfvars
```

Once again it'll prompt for the Hetzner API token and the name of the server. It will destroy everything in the Terraform state, so the name of the server doesn't really matter anymore.

# [Activity 2: Create a VM with our own tfvars](#activity-2-create-a-vm-with-our-own-tfvars)
This time, we'll create a custom `tfvars` file. 

## [Create custom tfvars](#create-custom-tfvars)
Let's create a `my.tfvars` file in `1-basic-create-vm/tfvars` with the following content:

```hcl
// Don't give the name, we don't want duplicates
# name = "<YOUR INITIALS>

domain = "terraform.test"
type = "cx21"

image = "ubuntu-20.04"

datacenter = "nbg1-dc3"

// My key already exists
new_ssh_keys = {
    "<YOUR INITIALS>" = "<YOUR SSH PUBKEY>"
}
```
###### Note: Replace `<YOUR INITIALS>` with your initials and `<YOUR SSH PUBKEY>` with your public SSH key. This is to prevent duplicate names.


## [Launch](#launch-1)
Now, let's create a VM with our custom `my.tfvars` file.
    
```bash
terraform plan -var-file tfvars/my.tfvars
terraform apply -var-file tfvars/my.tfvars
```

After it is created, you'll be able to log in.

## [Logging in](#logging-in)
We'll need to get the IP of the VM. We've defined this as an output in `outputs.tf`. We can get this with the following command:

```bash
terraform output primary_ipv4_address
```

Now, we can log in with the following command:

```bash
ssh root@<IP>
```
###### Note: Replace `<IP>` with the IP address you got from the output.

## [Destroy](#destroy-1)
To destroy the VM, run:

```bash
terraform destroy -var-file tfvars/my.tfvars
```

# [Code explanation](#code-explanation)

## [Files](#files)

File | Purpose | Notes
--- | --- | ---
[main.tf](main.tf) | Main Terraform file | Creates the server
[outputs.tf](outputs.tf) | Outputs | Outputs the IP address, name and domain of the server
[variables.tf](variables.tf) | Variables | Defines the variables used in the main file
[provider.tf](provider.tf) | Provider | Configures the Hetzner Cloud provider
[example.tfvars](tfvars/example.tfvars) | Example tfvars | Example tfvars file which fills in the required variables

## [Why is the `name` field in the server so complicated?](#why-is-the-name-field-in-the-server-so-complicated)
```hcl
name        = var.domain != null && var.domain != "" ? "${var.name}.${var.domain}" : var.name
```

The reason I do this is to check if the domain field is given. 
IF domain is defined and not an empty string, name it as `${var.name}.${var.domain}`  
ELSE name it as `${var.name}`

## [What is `depends_on`?](#what-is-depends_on)
```hcl
  depends_on = [
    hcloud_primary_ip.primary_ipv4,
    hcloud_ssh_key.new_ssh_keys
  ]
```
`depends_on` is a meta-argument that is used to specify the dependencies of a resource. This is used to ensure that the resources are created in the correct order. In this case, the IP address and the SSH keys must be created before the server is created.

## [Why is the `ssh_keys` field in the server so complicated?](#why-is-the-ssh_keys-field-in-the-server-so-complicated)
```hcl
ssh_keys = [for k, v in hcloud_ssh_key.new_ssh_keys : hcloud_ssh_key.new_ssh_keys[k].id]
```
This fetches every created SSH key and adds it to the server. This is useful when you have multiple SSH keys and you want to add them all to the server.

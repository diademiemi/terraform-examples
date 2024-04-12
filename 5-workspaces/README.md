# [5: Workspaces](#5-workspaces)

In this example, we use a module to create two VMs, the same as in the previous example, now with a module.

# Table of Contents
- [5: Workspaces](#5-workspaces)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Activity 1: Create VMs with example.tfvars](#activity-1-create-vms-with-exampletfvars)
  - [Install Terraform requirements](#install-terraform-requirements)
  - [Set up workspaces](#set-up-workspaces)
  - [Launch](#launch)
  - [Using a different workspace](#using-a-different-workspace)
  - [Destroy](#destroy)
- [Code explanation](#code-explanation)
  - [Files](#files)


# [Prerequisites](#prerequisites)
- Terraform installed
- Hetzner API token
- GitLab API token (for the remote state)

# [Activity 1: Create VMs with example.tfvars](#activity-1-create-vms-with-exampletfvars)

## [Install Terraform requirements](#install-terraform-requirements)
We need to first fetch the providers and module, even if it's a local path (like in this case). Run the following command:

```bash
terraform init
```

## [Set up workspaces](#set-up-workspaces)
Workspaces allow you to have multiple states in the same repository. This is useful for having different instances of the same infrastructure, like dev, staging, and production. It's also useful for having different configurations in the same repository. 

Without workspaces, Terraform would overwrite the state and destroy servers not present in the current configuration.
For example, creating a server `server1` in one run and then creating `server2` in another run would destroy `server1` if it also wasn't given in the second run.

With workspaces, we can isolate the states. This way, `server1` and `server2` can exist in different workspaces.

An alternative would be to configure multiple remote states, but switching between workspaces is much easier and more intuitive.

Let's create a workspace:

```bash
terraform workspace new workspace-1
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

It will prompt for the Hetzner API token and a suffix for the servers, please use your initials **followed by "-1" (e.g. `jk-1`)** (This is to prevent duplicates in the lab).

## [Using a different workspace](#set-up-a-different-workspace)
Let's create a different workspace:

```bash
terraform workspace new workspace-2
```

Now, let's create the VMs in this workspace:

```bash
# Check what will be created
terraform plan -var-file tfvars/example.tfvars

# Create the VM
terraform apply -var-file tfvars/example.tfvars
```

It will again prompt for the Hetzner API token and a suffix for the servers. This time, please use your initials **followed by "-2" (e.g. `jk-2`)**.

Both the `workspace-1` and `workspace-2` will have their own state files. This way, you can have different configurations in the same repository. A common usecase for this is to have a different `dev.tfvars` and `prod.tfvars`, still using the same code and contained in the same repository.

## [Destroy](#destroy)
To destroy the VM, run (in the Terraform directory, not Ansible directory):

```bash
export TF_WORKSPACE=workspace-1
terraform destroy -var-file tfvars/example.tfvars

export TF_WORKSPACE=workspace-2
terraform destroy -var-file tfvars/example.tfvars
```

Once again it'll prompt for the Hetzner API token and the name of the server (for both destroy commands). It will destroy everything in the Terraform workspace (one state for each workspace), so the suffixes of the servers don't really matter anymore.

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

# [4: Remote state](#4-remote-state)

In this example, we store our Terraform state in a remote location (GitLab). This allows multiple people to work on the same state file and provides a version history.

# Table of Contents
- [4: Remote state](#4-remote-state)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Activity 1: Create VMs with example.tfvars](#activity-1-create-vms-with-exampletfvars)
  - [Set up remote state and init](#set-up-remote-state-and-init)
  - [Launch](#launch)
  - [Destroy](#destroy)
- [Code explanation](#code-explanation)
  - [Files](#files)
  - [Setting the state](#setting-the-state)


# [Prerequisites](#prerequisites)
- Terraform installed
- Hetzner API token
- GitLab API token (for the remote state)

# [Activity 1: Create VMs with example.tfvars](#activity-1-create-vms-with-exampletfvars)

## [Set up remote state and init](#set-up-remote-state)
Terraform stores which resources it created in a "state file". This state file can be stored locally, usually in `terraform.tfstate` in the Terraform directory. But it's better to store it remotely. This way, multiple people can work on the same state file.
Other benefits include that the state file is locked when someone is working on it, so no two people can work on the same state file at the exact same time and corrupt it. Many remote state providers also include a version history for auditing.

In this example we'll be using GitLab as the remote state. We'll all use a shared repository for this so please set your own state name.
You'll need a GitLab API token to use the remote state. You can get this by going to your GitLab profile -> Settings -> Access Tokens -> Create a personal access token. Please export it as an environment variable:

One downside of using GitLab is that it does not support workspaces, this is something we'll cover in the next example. Other remote state providers like S3 or local files do support workspaces.

```bash
export GITLAB_ACCESS_TOKEN=<your token>
```

Export the following variables:

```bash
export TF_STATE_NAME=... # Your initials (e.g. jk)
export GITLAB_PROJECT_ID=... # I will communicate this to you. Or use any GitLab repository *that doesn't already have a Terraform state* (To prevent duplicates).
export GITLAB_URL_=... # e.g. https://gitlab.example.com

```
Now we can set up the remote state (as defined in `provider.tf`):

```bash
terraform init \
    -backend-config="address=$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/terraform/state/$TF_STATE_NAME" \
    -backend-config="lock_address=$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/terraform/state/$TF_STATE_NAME/lock" \
    -backend-config="unlock_address=$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/terraform/state/$TF_STATE_NAME/lock" \
    -backend-config="username=terraform" \
    -backend-config="password=$GITLAB_ACCESS_TOKEN" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"
```

This also initializes the providers and modules.

If you messed up here, you can retry the command if you append `-reconfigure`.

## [Launch](#launch)
Let's use the given `example.tfvars` file to create a VM.

Navigate to this directory and run:

```bash
# Check what will be created
terraform plan -var-file tfvars/example.tfvars

# Create the VM
terraform apply -var-file tfvars/example.tfvars
```

It will prompt for the Hetzner API token and a suffix for the servers, please use your initials followed by "-1" (e.g. `jk-1`) (This is to prevent duplicates in the lab).

## [Destroy](#destroy)
To destroy the VM, run (in the Terraform directory, not Ansible directory):

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
[server_module/main.tf](server_module/main.tf) | Module main file | Creates the server
[server_module/variables.tf](server_module/variables.tf) | Module variables | Defines the variables used in the module
[server_module/outputs.tf](server_module/outputs.tf) | Module outputs | Outputs the IP address, name and domain of the server
[server_module/provider.tf](server_module/provider.tf) | Module provider | Configures the Hetzner Cloud provider for the module

## [Setting the state](#setting-the-state)
The state is set in `provider.tf`:

```hcl
# Terraform config block
terraform {
  ...
  backend "http" {
  }
}
```

This defines that we're looking for a HTTP backend, and it will prevent the code from being ran until a remote state is configured.
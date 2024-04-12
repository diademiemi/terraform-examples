# Terraform Examples

This repository contains the Terraform examples used to teach Terraform to some colleagues.

Every lab is a self-contained project with its own `README.md` file which explains the lab and the topics covered.

## Labs

Project | Topics Covered
--- | ---
[1-basic-create-vm](./1-basic-create-vm/) | Using Terraform to create a basic VM. TFVars. Outputs.
[2-loops-and-data](./2-loops-and-data/) | Data sources. Loops.
[3-modulesand-ansible-inventory](./3-modules-and-ansible-inventory/) | Modules. Module sources. Module outputs. Ansible dynamic inventory.
[4-remote-state](./4-remote-state/) | Remote state.
[5-workspaces](./5-workspaces/) | Workspaces.

## Information
Every lab uses Hetzner Cloud and the `hcloud` provider. You need to have a Hetzner Cloud account and an API token to run the labs.
Labs 2 and onward expect an SSH key to already be present in your Hetzner Cloud account. You can create these in the Hetzner Cloud Console for the project or in the [.ssh-key-project.tf](./.ssh-key-project.tf) project.

Lab 1 requires these to *not* be set, as Hetzner does not accept duplicate SSH keys. Make sure to create these in between lab 1 and lab 2!

Lab 4 requires a GitLab instance and a project to store the remote state. You can use GitLab.com or a self-hosted GitLab instance. Get the project ID and an access token, the lab explains how to set these up. This lab can be skipped if you don't have a GitLab instance to use.
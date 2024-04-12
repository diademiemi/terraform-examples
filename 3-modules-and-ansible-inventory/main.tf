# Call the module with the list of servers
module "server_module" {
    # Define module source
    source = "./server_module"

    for_each = { for server in var.servers : server.name => server }

    name = "${each.value.name}-${var.suffix}"

    image = try(each.value.image, null)
    type = try(each.value.type, null)
    datacenter = try(each.value.datacenter, null)
    domain = try(each.value.domain, null)

    # All optional, these have sane defaults in the module
    ansible_name = try(each.value.ansible_name, null)
    ansible_host = try(each.value.ansible_host, null)
    ansible_user = try(each.value.ansible_user, null)
    ansible_ssh_pass = try(each.value.ansible_ssh_pass, null)
    ansible_groups = try(each.value.ansible_groups, null)
    ansible_ssh_private_key_file = try(each.value.ansible_ssh_private_key_file, null)
}
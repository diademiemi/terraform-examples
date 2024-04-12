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
}
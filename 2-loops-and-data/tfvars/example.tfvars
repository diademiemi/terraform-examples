// We don't want duplicates
# name = "my-server"

type = "cx21"

image = "ubuntu-20.04"

datacenter = "nbg1-dc3"

servers = [
    {
        name = "web-1"
        type = "cx11"
    },
    {
        name = "web-2"
        type = "cx11"
    }
]

# new_ssh_keys = {
#     "my-key" = "ssh-ed25519 ..."
# }
# when using the vault_token terraform resource we need to be able to renew and revoke tokens

path "auth/token/lookup-accessor" {
  capabilities = ["update"]
}

path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}


# The provisioner policy is for packer instances and other automation that requires read access to vault

path "dev/network/*"
{
  capabilities = ["list", "read"]
}

path "green/network/*"
{
  capabilities = ["list", "read"]
}

path "blue/network/*"
{
  capabilities = ["list", "read"]
}

path "main/data/network/*"
{
  capabilities = ["list", "read"]
}
# path "main/network/*"
# {
#   capabilities = ["list", "read"]
# }
# path "main/*"
# {
#   capabilities = ["create", "read", "update", "delete", "list"]
# }

path "main/data/user"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}

# target="{{ resourcetier }}/files{{ item.value.target }}"

path "dev/files/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "green/files/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "blue/files/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "main/data/files/*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
# path "main/files/*"
# {
#   capabilities = ["create", "read", "update", "delete", "list"]
# }

# # This allows the instance to generate certificates

# path "pki_int/issue/*" {
#     capabilities = ["create", "update"]
# }

# path "pki_int/certs" {
#     capabilities = ["list"]
# }

# path "pki_int/revoke" {
#     capabilities = ["create", "update"]
# }

# path "pki_int/tidy" {
#     capabilities = ["create", "update"]
# }

# path "pki/cert/ca" {
#     capabilities = ["read"]
# }

path "auth/token/renew" {
    capabilities = ["update"]
}

path "auth/token/renew-self" {
    capabilities = ["update"]
}
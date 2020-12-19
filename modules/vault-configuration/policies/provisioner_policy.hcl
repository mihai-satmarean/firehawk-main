# The provisioner policy is for packer instances and other automation that requires read access to vault

path "dev/*"
{
  capabilities = ["list", "read"]
}

path "dev/data/user"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}

# This allows the instance to generate certificates

path "pki_int/issue/*" {
    capabilities = ["create", "update"]
}

path "pki_int/certs" {
    capabilities = ["list"]
}

path "pki_int/revoke" {
    capabilities = ["create", "update"]
}

path "pki_int/tidy" {
    capabilities = ["create", "update"]
}

path "pki/cert/ca" {
    capabilities = ["read"]
}

path "auth/token/renew" {
    capabilities = ["update"]
}

path "auth/token/renew-self" {
    capabilities = ["update"]
}
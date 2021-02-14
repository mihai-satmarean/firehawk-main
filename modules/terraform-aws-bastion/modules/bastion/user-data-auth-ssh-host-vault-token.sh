#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode. Note that this script assumes it's running in an AMI
# built from the Packer template in examples/vault-consul-ami/vault-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Log the given message. All logs are written to stderr with a timestamp.
function log {
 local -r message="$1"
 local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
 >&2 echo -e "$timestamp $message"
}

# log "Reconfigure network insterfaces..."
# rm -fr /etc/sysconfig/network-scripts/ifcfg-eth0 # this may need to be removed from the image. having a leftover network interface file here if the interface is not present can cause dns issues and slowdowns with sudo.

# yum install -y NetworkManager
# systemctl disable NetworkManager
# systemctl status NetworkManager  # -> inactive
# systemctl stop network
# systemctl start network
# # systemctl start NetworkManager
# systemctl start network.service
# systemctl start network

function has_yum {
  [[ -n "$(command -v yum)" ]]
}

if $(has_yum); then
    hostname=$(hostname -s) # in centos, failed dns lookup can cause commands to slowdown
    echo "127.0.0.1   $hostname.${aws_domain} $hostname" | tee -a /etc/hosts
    hostnamectl set-hostname $hostname.${aws_domain} # Red hat recommends that the hostname uses the FQDN.  hostname -f to resolve the domain may not work at this point on boot, so we use a var.
    systemctl restart network
fi

log "hostname: $(hostname)"
log "hostname: $(hostname -f) $(hostname -s)"

# This tests a bug that is present in the centos base AMI.
# log "test sudo delay"
# log "no sudo"
# sudo echo "sudo"
# log "sudo"
# log "no sudo"
# sudo echo "sudo"
# log "sudo"
# log "no sudo"

# These variables are passed in via Terraform template interpolation
/opt/consul/bin/run-consul --client --cluster-tag-key "${consul_cluster_tag_key}" --cluster-tag-value "${consul_cluster_tag_value}"

# A retry function that attempts to run a command a number of times and returns the output
function retry {
  local -r cmd="$1"
  local -r description="$2"

  for i in $(seq 1 30); do
    log "$description"

    # The boolean operations with the exit status are there to temporarily circumvent the "set -e" at the
    # beginning of this script which exits the script immediatelly for error status while not losing the exit status code
    output=$(eval "$cmd") && exit_status=0 || exit_status=$?
    errors=$(echo "$output") | grep '^{' | jq -r .errors

    log "$output"

    if [[ $exit_status -eq 0 && -z "$errors" ]]; then
      echo "$output"
      return
    fi
    log "$description failed. Will sleep for 10 seconds and try again."
    sleep 10
  done;

  log "$description failed after 30 attempts."
  exit $exit_status
}

# If vault cli is installed we can also perform these operations with vault cli
# The necessary environment variables have to be set
export VAULT_TOKEN=${vault_token}
export VAULT_ADDR=https://vault.service.consul:8200

# Retry and wait for the Vault Agent to write the token out to a file.  This could be
# because the Vault server is still booting and unsealing, or because run-consul
# running on the background didn't finish yet

# "vault login  --no-print ${vault_token}"

retry \
  "vault login --no-print $VAULT_TOKEN" \
  "Waiting for Vault login"

echo "Aquiring vault data..."

### Sign SSH host key
echo "Request Vault sign's the SSH host key and becomes a known host for other machines."

trusted_ca="/etc/ssh/trusted-user-ca-keys.pem"
# Aquire the public CA cert to approve an authority
vault read -field=public_key ssh-client-signer/config/ca | tee $trusted_ca
if test ! -f "$trusted_ca"; then
    echo "Missing $trusted_ca"
    exit 1
fi

# echo "LogLevel VERBOSE" | tee --append /etc/ssh/sshd_config # for debug
# If TrustedUserCAKeys not defined, then add it to sshd_config
grep -q "^TrustedUserCAKeys" /etc/ssh/sshd_config || echo 'TrustedUserCAKeys' | tee --append /etc/ssh/sshd_config
# Ensure the value for TrustedUserCAKeys is configured correctly
sed -i "s@TrustedUserCAKeys.*@TrustedUserCAKeys $trusted_ca@g" /etc/ssh/sshd_config 

if test ! -f "/etc/ssh/ssh_host_rsa_key.pub"; then
    echo "Missing public host key /etc/ssh/ssh_host_rsa_key.pub"
    exit 1
fi
# Sign this host's public key
vault write -format=json ssh-host-signer/sign/hostrole \
    cert_type=host \
    public_key=@/etc/ssh/ssh_host_rsa_key.pub

# Aquire the cert
vault write -field=signed_key ssh-host-signer/sign/hostrole \
    cert_type=host \
    public_key=@/etc/ssh/ssh_host_rsa_key.pub | tee /etc/ssh/ssh_host_rsa_key-cert.pub

if test ! -f "/etc/ssh/ssh_host_rsa_key-cert.pub"; then
    echo "Failed to aquire /etc/ssh/ssh_host_rsa_key-cert.pub"
    exit 1
fi

chmod 0640 /etc/ssh/ssh_host_rsa_key-cert.pub

# Private key and cert are both required for ssh to another host.  Multiple entries for host key may exist.
grep -q "^HostKey /etc/ssh/ssh_host_rsa_key" /etc/ssh/sshd_config || echo 'HostKey /etc/ssh/ssh_host_rsa_key' | tee --append /etc/ssh/sshd_config

# Configure single entry for host cert
grep -q "^HostCertificate" /etc/ssh/sshd_config || echo 'HostCertificate' | tee --append /etc/ssh/sshd_config
sed -i 's@HostCertificate.*@HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub@g' /etc/ssh/sshd_config

# Add the CA cert to use it for known host verification
# curl http://vault.service.consul:8200/v1/ssh-host-signer/public_key
key="$(vault read -field=public_key ssh-host-signer/config/ca)"

# ssh_known_hosts_path=/etc/ssh/ssh_known_hosts
function ensure_known_hosts {
  local -r ssh_known_hosts_path="$1"
  if test ! -f $ssh_known_hosts_path; then
      echo "Creating $ssh_known_hosts_path"
      touch $ssh_known_hosts_path # ensure known hosts file exists
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then # Acquire file permissions.
      octal_permissions=$(stat -f %A "$ssh_known_hosts_path" | rev | sed -E 's/^([[:digit:]]{4})([^[:space:]]+)/\1/' | rev ) # clip to 4 zeroes
  else
      octal_permissions=$(stat --format '%a' "$ssh_known_hosts_path" | rev | sed -E 's/^([[:digit:]]{4})([^[:space:]]+)/\1/' | rev) # clip to 4 zeroes
  fi
  octal_permissions=$( python -c "print( \"$octal_permissions\".zfill(4) )" ) # pad to 4 zeroes
  echo "$ssh_known_hosts_path octal_permissions currently $octal_permissions."
  if [[ "$octal_permissions" != "0644" ]]; then
      echo "...Setting to 0644"
      chmod 0644 $ssh_known_hosts_path
  fi

  grep -q "^@cert-authority \*\.consul" $ssh_known_hosts_path || echo '@cert-authority *.consul' | tee --append $ssh_known_hosts_path
  sed -i "s#@cert-authority \*\.consul.*#@cert-authority *.consul $key#g" $ssh_known_hosts_path
  ls -ltriah $ssh_known_hosts_path
  echo "Added CA to $ssh_known_hosts_path."
}
ensure_known_hosts /etc/ssh/ssh_known_hosts
ensure_known_hosts /home/centos/.ssh/known_host
# centos / amazon linux, restart ssh service
systemctl restart sshd

log "Signing SSH host key done. Revoking vault token..."
vault token revoke -self
# if this script fails, we can set the instance health status but we need to capture a fault
# aws autoscaling set-instance-health --instance-id i-0b03e12682e74746e --health-status Unhealthy

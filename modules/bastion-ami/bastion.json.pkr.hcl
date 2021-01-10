# This file was autogenerated by the BETA 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/from-1.5/variables#type-constraints for more info.
variable "aws_region" {
  type = string
  default = null
}

variable "ca_public_key_path" {
  type    = string
  default = "/home/ec2-user/.ssh/tls/ca.crt.pem"
}

variable "install_auth_signing_script" {
  type    = string
  default = "true"
}

locals {
  timestamp    = regex_replace(timestamp(), "[- TZ:]", "")
  template_dir = path.root
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
#could not parse template for following block: "template: generated:4: function \"clean_resource_name\" not defined"

source "amazon-ebs" "amazon-linux-2-ami" {
  ami_description = "An Amazon Linux 2 AMI that will accept connections from hosts with TLS Certs."
  ami_name        = "firehawk-base-amazon-linux-2-${local.timestamp}-{{uuid}}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami_filter {
    filters = {
      architecture                       = "x86_64"
      "block-device-mapping.volume-type" = "gp2"
      name                               = "*amzn2-ami-hvm-*"
      root-device-type                   = "ebs"
      virtualization-type                = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}

#could not parse template for following block: "template: generated:4: function \"clean_resource_name\" not defined"

source "amazon-ebs" "centos7-ami" {
  ami_description = "A Cent OS 7 AMI that will accept connections from hosts with TLS Certs."
  ami_name        = "firehawk-base-centos7-${local.timestamp}-{{uuid}}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami_filter {
    filters = {
      name         = "CentOS Linux 7 x86_64 HVM EBS *"
      product-code = "aw0evgkw8e5c1q413zgy5pjce"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  ssh_username = "centos"
}

#could not parse template for following block: "template: generated:4: function \"clean_resource_name\" not defined"

source "amazon-ebs" "ubuntu16-ami" {
  ami_description = "An Ubuntu 16.04 AMI that will accept connections from hosts with TLS Certs."
  ami_name        = "firehawk-base-ubuntu16-${local.timestamp}-{{uuid}}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami_filter {
    filters = {
      architecture                       = "x86_64"
      "block-device-mapping.volume-type" = "gp2"
      name                               = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
      root-device-type                   = "ebs"
      virtualization-type                = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

source "amazon-ebs" "ubuntu18-ami" {
  ami_description = "An Ubuntu 18.04 AMI that will accept connections from hosts with TLS Certs."
  ami_name        = "firehawk-base-ubuntu18-${local.timestamp}-{{uuid}}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami_filter {
    filters = {
      architecture                       = "x86_64"
      "block-device-mapping.volume-type" = "gp2"
      name                               = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
      root-device-type                   = "ebs"
      virtualization-type                = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

source "amazon-ebs" "openvpn-server-ami" { # Open vpn server requires vault and consul, so we build it here as well.
  ami_description = "An Open VPN Access Server AMI configured for Firehawk"
  ami_name        = "firehawk-openvpn-server-base-${local.timestamp}-{{uuid}}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  user_data = <<EOF
#! /bin/bash
admin_user=openvpnas
admin_pw=''
EOF
  # user_data_file  = "${local.template_dir}/openvpn_user_data.sh"
  source_ami_filter {
    filters = {
      description  = "OpenVPN Access Server 2.8.3 publisher image from https://www.openvpn.net/."
      product-code = "f2ew2wrz425a1jagnifd02u5t"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  ssh_username = "openvpnas"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.amazon-ebs.amazon-linux-2-ami",
  "source.amazon-ebs.centos7-ami",
  "source.amazon-ebs.ubuntu16-ami",
  "source.amazon-ebs.ubuntu18-ami",
  "source.amazon-ebs.openvpn-server-ami"
  ]
  provisioner "shell" {
    inline         = ["echo 'init success'"]
    inline_shebang = "/bin/bash -e"
  }

  provisioner "shell" {
    inline         = ["sudo echo 'sudo echo test'"] # verify sudo is available
    inline_shebang = "/bin/bash -e"
  }

  provisioner "shell" {
    only           = [
    "amazon-ebs.ubuntu16-ami",
    "amazon-ebs.ubuntu18-ami",
    "amazon-ebs.openvpn-server-ami"
    ]
    inline         = [
        "unset HISTFILE",
        "history -cw",
        "echo === Waiting for Cloud-Init ===",
        "timeout 180 /bin/bash -c 'until stat /var/lib/cloud/instance/boot-finished &>/dev/null; do echo waiting...; sleep 6; done'",
        "echo === System Packages ===",
        "echo 'connected success'",
        "sudo systemd-run --property='After=apt-daily.service apt-daily-upgrade.service' --wait /bin/true; echo \"exit $?\""
        ]
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline_shebang = "/bin/bash -e"
  }

  ### Start Prepare Open VPN Image ###
  
  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    only           = ["amazon-ebs.openvpn-server-ami"]
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline         = [
      "export SHOWCOMMANDS=true; set -x",
      # "lsb_release -a",
      # "ps aux | grep [a]pt",
      "sudo cat /etc/systemd/system.conf",
      "sudo chown openvpnas:openvpnas /home/openvpnas; echo \"exit $?\"",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections; echo \"exit $?\"",
      "ls -ltriah /var/cache/debconf/passwords.dat; echo \"exit $?\"",
      "ls -ltriah /var/cache/; echo \"exit $?\""
    ]
  }

  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    only           = ["amazon-ebs.openvpn-server-ami"]
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    valid_exit_codes = [0,1] # ignore exit code.  this requirement is a bug in the open vpn ami.
    inline         = [
      "sudo add-apt-repository universe",
      "set -x; sudo apt-get -y install dialog; echo \"exit $?\"" # supressing exit code.
    ]
  }

  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    only           = ["amazon-ebs.openvpn-server-ami"]
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline         = [
      "DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -q; echo \"exit $?\""
    ]
  }

  ### End Prepare Open VPN Image ###

  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    only           = [ 
      "amazon-ebs.ubuntu16-ami",
      "amazon-ebs.ubuntu18-ami",
      "amazon-ebs.openvpn-server-ami"
      ]
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline         = [
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections", 
      "sudo apt-get install -y -q"
    ]
  }

  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    only           = [ 
      "amazon-ebs.ubuntu16-ami",
      "amazon-ebs.ubuntu18-ami",
      "amazon-ebs.openvpn-server-ami"
      ]
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline         = [ 
      "sudo apt-get install dpkg -y"
    ]
  }

  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    only           = [ 
      "amazon-ebs.ubuntu16-ami",
      "amazon-ebs.ubuntu18-ami",
      "amazon-ebs.openvpn-server-ami"
      ]
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline         = [
      "sudo apt-get -y update"
    ]
  }

  provisioner "shell" {
    inline = ["mkdir -p /tmp/terraform-aws-vault/modules"]
  }

  #could not parse template for following block: "template: generated:3: function \"template_dir\" not defined"
  provisioner "file" {
    destination = "/tmp/terraform-aws-vault/modules"
    source      = "${local.template_dir}/../terraform-aws-vault/modules/"
  }

  #could not parse template for following block: "template: generated:3: function \"template_dir\" not defined"
  provisioner "file" {
    destination = "/tmp/sign-request.py"
    source      = "${local.template_dir}/auth/sign-request.py"
  }
  provisioner "file" {
    destination = "/tmp/ca.crt.pem"
    source      = "${var.ca_public_key_path}"
  }
  provisioner "shell" {
    inline         = [
      "if [[ '${var.install_auth_signing_script}' == 'true' ]]; then",
      "sudo mkdir -p /opt/vault/scripts/",
      "sudo mv /tmp/sign-request.py /opt/vault/scripts/",
      "else",
      "sudo rm /tmp/sign-request.py", 
      "fi",
      "sudo mkdir -p /opt/vault/tls/", 
      "sudo mv /tmp/ca.crt.pem /opt/vault/tls/", 
      "sudo chmod -R 600 /opt/vault/tls", 
      "sudo chmod 700 /opt/vault/tls", 
      "sudo /tmp/terraform-aws-vault/modules/update-certificate-store/update-certificate-store --cert-file-path /opt/vault/tls/ca.crt.pem"
    ]
    inline_shebang = "/bin/bash -e"
  }
  provisioner "shell" {
    inline         = ["sudo systemd-run --property='After=apt-daily.service apt-daily-upgrade.service' --wait /bin/true"]
    inline_shebang = "/bin/bash -e"
    only           = [ 
      "amazon-ebs.ubuntu16-ami",
      "amazon-ebs.ubuntu18-ami",
      "amazon-ebs.openvpn-server-ami"
      ]
  }
  provisioner "shell" {
    inline         = ["echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections", "sudo apt-get install -y -q", "sudo apt-get -y update", "sudo apt-get install -y git"]
    inline_shebang = "/bin/bash -e"
    only           = [ 
      "amazon-ebs.ubuntu16-ami",
      "amazon-ebs.ubuntu18-ami",
      "amazon-ebs.openvpn-server-ami"
      ]
  }
  provisioner "shell" {
    inline         = [
      # "sudo apt-get -y install python3.7",
      # "sudo dpkg --get-selections | grep hold",
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install -y python3-pip",
      "python3 -m pip install --upgrade pip",
      "python3 -m pip install boto3",
      "python3 -m pip --version"
      ]
    inline_shebang = "/bin/bash -e"
    only           = [ 
      "amazon-ebs.ubuntu16-ami",
      "amazon-ebs.ubuntu18-ami",
      "amazon-ebs.openvpn-server-ami"
    ]
  }
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sleep 5",
      "sudo yum install -y git",
      "sudo yum install -y python python3.7 python3-pip",
      "python3 -m pip install --user --upgrade pip",
      "python3 -m pip install --user boto3"
      ]
    only   = ["amazon-ebs.amazon-linux-2-ami", "amazon-ebs.centos7-ami"]
  }

  post-processor "manifest" {
      output = "${local.template_dir}/manifest.json"
      strip_path = true
      custom_data = {
        timestamp = "${local.timestamp}"
      }
  }
}



# Example query for the output ami:
# #!/bin/bash

# AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ":" -f2)
# echo $AMI_ID
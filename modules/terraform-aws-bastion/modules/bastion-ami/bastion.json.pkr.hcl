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
  type    = string
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

variable "resourcetier" {
  type = string
}

variable "consul_download_url" {
  type    = string
  default = ""
}

variable "consul_module_version" {
  type    = string
  default = "v0.8.0"
}

variable "consul_version" {
  type    = string
  default = "1.8.4"
}

variable "vault_download_url" {
  type    = string
  default = ""
}

variable "vault_version" {
  type    = string
  default = "1.5.5"
}

variable "consul_cluster_tag_key" {
  type = string
}

variable "consul_cluster_tag_value" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "amazon_linux_2_ami" {
  type = string
}

variable "ubuntu16_ami" {
  type = string
}

variable "ubuntu18_ami" {
  type = string
}

variable "centos7_ami" {
  type = string
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
  source_ami      = "${var.amazon_linux_2_ami}"
  # source_ami_filter {
  #   filters = {
  #     architecture                       = "x86_64"
  #     "block-device-mapping.volume-type" = "gp2"
  #     name                               = "*amzn2-ami-hvm-*"
  #     root-device-type                   = "ebs"
  #     virtualization-type                = "hvm"
  #   }
  #   most_recent = true
  #   owners      = ["amazon"]
  # }
  ssh_username = "ec2-user"

  vpc_id               = "${var.vpc_id}"
  subnet_id            = "${var.subnet_id}"
  security_group_id    = "${var.security_group_id}"
  iam_instance_profile = "provisioner_instance_role_pipeid0"
}

#could not parse template for following block: "template: generated:4: function \"clean_resource_name\" not defined"

source "amazon-ebs" "centos7-ami" {
  ami_description = "A Cent OS 7 AMI that will accept connections from hosts with TLS Certs."
  ami_name        = "firehawk-base-centos7-${local.timestamp}-{{uuid}}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami      = "${var.centos7_ami}"
  # source_ami_filter {
  #   filters = {
  #     name         = "CentOS Linux 7 x86_64 HVM EBS *"
  #     product-code = "aw0evgkw8e5c1q413zgy5pjce"
  #   }
  #   most_recent = true
  #   owners      = ["679593333241"]
  # }
  ssh_username = "centos"

  vpc_id               = "${var.vpc_id}"
  subnet_id            = "${var.subnet_id}"
  security_group_id    = "${var.security_group_id}"
  iam_instance_profile = "provisioner_instance_role_pipeid0"
}

#could not parse template for following block: "template: generated:4: function \"clean_resource_name\" not defined"

source "amazon-ebs" "ubuntu16-ami" {
  ami_description = "An Ubuntu 16.04 AMI that will accept connections from hosts with TLS Certs."
  ami_name        = "firehawk-base-ubuntu16-${local.timestamp}-{{uuid}}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami      = "${var.ubuntu16_ami}"
  # source_ami_filter {
  #   filters = {
  #     architecture                       = "x86_64"
  #     "block-device-mapping.volume-type" = "gp2"
  #     name                               = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
  #     root-device-type                   = "ebs"
  #     virtualization-type                = "hvm"
  #   }
  #   most_recent = true
  #   owners      = ["099720109477"]
  # }
  ssh_username = "ubuntu"

  vpc_id               = "${var.vpc_id}"
  subnet_id            = "${var.subnet_id}"
  security_group_id    = "${var.security_group_id}"
  iam_instance_profile = "provisioner_instance_role_pipeid0"
}

#could not parse template for following block: "template: generated:4: function \"clean_resource_name\" not defined"

source "amazon-ebs" "ubuntu18-ami" {
  ami_description = "An Ubuntu 18.04 AMI that will accept connections from hosts with TLS Certs."
  ami_name        = "firehawk-base-ubuntu18-${local.timestamp}-{{uuid}}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami      = "${var.ubuntu18_ami}"
  # source_ami_filter {
  #   filters = {
  #     architecture                       = "x86_64"
  #     "block-device-mapping.volume-type" = "gp2"
  #     name                               = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  #     root-device-type                   = "ebs"
  #     virtualization-type                = "hvm"
  #   }
  #   most_recent = true
  #   owners      = ["099720109477"]
  # }
  ssh_username = "ubuntu"

  vpc_id               = "${var.vpc_id}"
  subnet_id            = "${var.subnet_id}"
  security_group_id    = "${var.security_group_id}"
  iam_instance_profile = "provisioner_instance_role_pipeid0"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.amazon-ebs.amazon-linux-2-ami", "source.amazon-ebs.centos7-ami", "source.amazon-ebs.ubuntu18-ami"]

  provisioner "shell" {
    inline = ["mkdir -p /tmp/terraform-aws-vault/modules"]
  }

  #could not parse template for following block: "template: generated:3: function \"template_dir\" not defined"
  provisioner "file" {
    destination = "/tmp/terraform-aws-vault/modules"
    source      = "${local.template_dir}/../../../terraform-aws-vault/modules/"
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
    inline = [
      "echo \"hostname: $(sudo hostnamectl)\"",
      "sudo cat /etc/hostname",
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
    only           = ["amazon-ebs.ubuntu18-ami"]
  }
  provisioner "shell" {
    inline         = ["echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections", "sudo apt-get install -y -q", "sudo apt-get -y update", "sudo apt-get install -y git"]
    inline_shebang = "/bin/bash -e"
    only           = ["amazon-ebs.ubuntu16-ami", "amazon-ebs.ubuntu18-ami"]
  }
  provisioner "shell" {
    inline = [
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
    only           = ["amazon-ebs.ubuntu18-ami"]
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
    only = ["amazon-ebs.amazon-linux-2-ami", "amazon-ebs.centos7-ami"]
  }

  ### This block will install Vault and Consul Agent

  provisioner "shell" { # Vault client probably wont be installed on bastions in future, but most hosts that will authenticate will require it.
    inline = [
      "if test -n '${var.vault_download_url}'; then",
      " /tmp/terraform-aws-vault/modules/install-vault/install-vault --download-url ${var.vault_download_url};",
      "else",
      " /tmp/terraform-aws-vault/modules/install-vault/install-vault --version ${var.vault_version};",
      "fi"
    ]
  }

  # provisioner "shell" {
  #   inline = [
  #     "sudo apt-get install -y git",
  #     "if [[ '${var.install_auth_signing_script}' == 'true' ]]; then",
  #     "sudo apt-get install -y python-pip",
  #     "LC_ALL=C && sudo pip install boto3",
  #   "fi"]
  #   inline_shebang = "/bin/bash -e"
  #   # only           = ["amazon-ebs.ubuntu16-ami", "amazon-ebs.ubuntu18-ami"]
  # }

  provisioner "shell" { # jq requires this repo on centos 7, and the dig command is also required
    inline = [
      "sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
      "sudo yum -y install bind-utils jq"
    ]
    only = ["amazon-ebs.centos7-ami"]
  }


  provisioner "shell" {
    inline = [
      "git clone --branch ${var.consul_module_version} https://github.com/hashicorp/terraform-aws-consul.git /tmp/terraform-aws-consul",
      "if test -n \"${var.consul_download_url}\"; then",
      " /tmp/terraform-aws-consul/modules/install-consul/install-consul --download-url ${var.consul_download_url};",
      "else",
      " /tmp/terraform-aws-consul/modules/install-consul/install-consul --version ${var.consul_version};",
    "fi"]
  }

  provisioner "shell" { # configure systemd-resolved
    inline = [
      "set -x; sudo sed -i \"s/#Domains=/Domains=~service.consul./g\" /etc/systemd/resolved.conf",
      "set -x; /tmp/terraform-aws-consul/modules/setup-systemd-resolved/setup-systemd-resolved",
      "set -x; sudo systemctl daemon-reload",
      "set -x; sudo systemctl restart systemd-resolved",
      "set -x; sudo cat /etc/systemd/resolved.conf",
    ]
    only = ["amazon-ebs.ubuntu18-ami"]
  }
  provisioner "shell" {
    inline = ["/tmp/terraform-aws-consul/modules/install-dnsmasq/install-dnsmasq"]
    only   = ["amazon-ebs.ubuntu16-ami", "amazon-ebs.amazon-linux-2-ami"]
  }

  provisioner "shell" { # Generate certificates with vault.
    inline = [
      "set -x; sudo /opt/consul/bin/run-consul --client --cluster-tag-key \"${var.consul_cluster_tag_key}\" --cluster-tag-value \"${var.consul_cluster_tag_value}\"", # this is normally done with user data but dont for convenience here
      "set -x; consul members list",
      "set -x; dig $(hostname) | awk '/^;; ANSWER SECTION:$/ { getline ; print $5 ; exit }'", # check localhost resolve's
      # test=$(ls -A); if [[ $? != 0 ]]; then; echo "Command failed."; fi
      "set -x; dig @127.0.0.1 vault.service.consul | awk '/^;; ANSWER SECTION:$/ { getline ; print $5 ; exit }'", # check consul will resolve vault
      "set -x; dig @localhost vault.service.consul | awk '/^;; ANSWER SECTION:$/ { getline ; print $5 ; exit }'", # check localhost will resolve vault
      "set -x; dig vault.service.consul | awk '/^;; ANSWER SECTION:$/ { getline ; print $5 ; exit }'",            # check default lookup will resolve vault
    ]
    # only = ["amazon-ebs.ubuntu18-ami"]
  }

  post-processor "manifest" {
    output     = "${local.template_dir}/manifest.json"
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

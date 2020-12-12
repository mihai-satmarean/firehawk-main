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

variable "general_host_ubuntu18_ami" {
  type = string
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
  type    = string
}

locals {
  timestamp    = regex_replace(timestamp(), "[- TZ:]", "")
  template_dir = path.root
  bucket_extension = vault("/${var.resourcetier}/data/aws/bucket_extension", "value") # vault refs in packer use the api path, not the cli path
  deadline_version = vault("/${var.resourcetier}/data/deadline/deadline_version", "value")
  # syscontrol_gid = vault("/${var.resourcetier}/data/system/syscontrol_gid", "value")
  # deployuser_uid = vault("/${var.resourcetier}/data/system/deployuser_uid", "value")
  # deadlineuser_uid = vault("/${var.resourcetier}/data/system/deadlineuser_uid", "value")
  installers_bucket = vault("/main/data/aws/installers_bucket", "value")
  # user_deadlineuser_pw = "fghthgmjg"
  # deadline_proxy_certificate_password = "fghthgmjg"
}

source "amazon-ebs" "ubuntu18-ami" {
  ami_description = "An Ubuntu 18.04 AMI containing a Deadline DB server."
  ami_name        = "firehawk-deadlinedb-ubuntu18-${local.timestamp}-{{uuid}}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  iam_instance_profile = "provisioner_instance_role_pipeid0"
  source_ami      = "${var.general_host_ubuntu18_ami}"
  ssh_username    = "ubuntu"
  # assume_role { # Since we need to read files from s3, we require a role with read access.
  #     role_arn     = "arn:aws:iam::972620357255:role/provisioner_instance_role_pipeid0" # This needs to be replaced with a terraform output
  #     session_name = "SESSION_NAME"
  #     # external_id  = "EXTERNAL_ID"
  # }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu18-ami"
    ]
  provisioner "shell" {
    inline         = ["sudo systemd-run --property='After=apt-daily.service apt-daily-upgrade.service' --wait /bin/true"]
    inline_shebang = "/bin/bash -e"
    # only           = ["amazon-ebs.ubuntu18-ami"]
  }
  # provisioner "shell" {
  #   inline         = ["echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections", "sudo apt-get install -y -q", "sudo apt-get -y update", "sudo apt-get install -y git"]
  #   inline_shebang = "/bin/bash -e"
  #   # only           = ["amazon-ebs.ubuntu16-ami", "amazon-ebs.ubuntu18-ami"]
  # }
  # provisioner "shell" {
  #   inline         = [
  #     # "sudo apt-get -y install python3.7",
  #     # "sudo dpkg --get-selections | grep hold",
  #     "sudo apt update -y",
  #     "sudo apt upgrade -y",
  #     "sudo apt install -y python3-pip",
  #     "python3 -m pip install --upgrade pip",
  #     "python3 -m pip install boto3",
  #     "python3 -m pip --version"
  #     ]
  #   inline_shebang = "/bin/bash -e"
  #   only           = ["amazon-ebs.ubuntu18-ami"]
  # }
  # provisioner "ansible" {
  #   playbook_file = "./ansible/newuser_deadlineuser.yaml"
  #   extra_arguments = [
  #     "-v",
  #     "--extra-vars",
  #     "user_deadlineuser_name=ubuntu variable_host=default variable_connect_as_user=ubuntu variable_user=deployuser sudo=true add_to_group_syscontrol=true create_ssh_key=false variable_uid=${local.deployuser_uid} delegate_host=localhost syscontrol_gid=${local.syscontrol_gid}"
  #   ]
  #   collections_path = "./ansible/collections"
  #   roles_path = "./ansible/roles"
  #   ansible_env_vars = [ "ANSIBLE_CONFIG=ansible/ansible.cfg" ]
  #   galaxy_file = "./requirements.yml"
  # }

  # provisioner "ansible" {
  #   playbook_file = "./ansible/newuser_deadlineuser.yaml"
  #   extra_arguments = [
  #     "-v",
  #     "--extra-vars",
  #     "user_deadlineuser_name=ubuntu variable_host=default variable_connect_as_user=ubuntu variable_user=deadlineuser sudo=false add_to_group_syscontrol=false create_ssh_key=false variable_uid=${local.deadlineuser_uid} delegate_host=localhost syscontrol_gid=${local.syscontrol_gid}"
  #   ]
  #   collections_path = "./ansible/collections"
  #   roles_path = "./ansible/roles"
  #   ansible_env_vars = [ "ANSIBLE_CONFIG=ansible/ansible.cfg" ]
  #   galaxy_file = "./requirements.yml"
  # }

  # provisioner "ansible" {
  #   playbook_file = "./ansible/aws_cli_ec2_install.yaml"
  #   extra_arguments = [
  #     "-v",
  #     "--extra-vars",
  #     "variable_host=default variable_connect_as_user=ubuntu variable_user=ubuntu variable_become_user=ubuntu delegate_host=localhost",
  #     "--skip-tags",
  #     "user_access"
  #   ]
  #   collections_path = "./ansible/collections"
  #   roles_path = "./ansible/roles"
  #   ansible_env_vars = [ "ANSIBLE_CONFIG=ansible/ansible.cfg" ]
  #   galaxy_file = "./requirements.yml"
  # }

  # provisioner "ansible" {
  #   playbook_file = "./ansible/aws_cli_ec2_install.yaml"
  #   extra_arguments = [
  #     "-v",
  #     "--extra-vars",
  #     "variable_host=default variable_connect_as_user=ubuntu variable_user=ubuntu variable_become_user=deadlineuser delegate_host=localhost",
  #     "--skip-tags",
  #     "user_access"
  #   ]
  #   collections_path = "./ansible/collections"
  #   roles_path = "./ansible/roles"
  #   ansible_env_vars = [ "ANSIBLE_CONFIG=ansible/ansible.cfg" ]
  #   galaxy_file = "./requirements.yml"
  # }

# ansible-playbook -i "$TF_VAR_inventory" ansible/aws-cli-ec2-install.yaml -v --extra-vars "variable_host=role_node_centos variable_user=centos variable_become_user=deadlineuser" --skip-tags "user_access"; exit_test
# ansible-playbook -i "$TF_VAR_inventory" ansible/aws-cli-ec2-install.yaml -vv --extra-vars "variable_host=workstation1 variable_user=deadlineuser aws_cli_root=true ansible_ssh_private_key_file=$TF_VAR_onsite_workstation_private_ssh_key"; exit_test

  provisioner "ansible" {
    playbook_file = "./ansible/transparent-hugepages-disable.yml"
    extra_arguments = [
      "-v",
      "--extra-vars",
      # "user_deadlineuser_pw=${local.user_deadlineuser_pw} user_deadlineuser_name=deadlineuser variable_host=default variable_connect_as_user=ubuntu delegate_host=localhost"
      "user_deadlineuser_name=ubuntu variable_host=default variable_connect_as_user=ubuntu delegate_host=localhost"
    ]
    collections_path = "./ansible/collections"
    roles_path = "./ansible/roles"
    ansible_env_vars = [ "ANSIBLE_CONFIG=ansible/ansible.cfg" ]
    galaxy_file = "./requirements.yml"
  }

  provisioner "ansible" {
    playbook_file = "./ansible/deadline-db-install.yaml"
    extra_arguments = [
      "-vvv",
      "--extra-vars",
      # "user_deadlineuser_pw=${local.user_deadlineuser_pw} user_deadlineuser_name=deployuser variable_host=default variable_connect_as_user=ubuntu delegate_host=localhost openfirehawkserver=deadlinedb.service.consul deadline_proxy_certificate_password=${local.deadline_proxy_certificate_password} installers_bucket=${local.installers_bucket} deadline_version=${local.deadline_version} reinstallation=false"
      "user_deadlineuser_name=ubuntu variable_host=default variable_connect_as_user=ubuntu delegate_host=localhost openfirehawkserver=deadlinedb.service.consul installers_bucket=${local.installers_bucket} deadline_version=${local.deadline_version} reinstallation=false"
    ]
    collections_path = "./ansible/collections"
    roles_path = "./ansible/roles"
    ansible_env_vars = [ "ANSIBLE_CONFIG=ansible/ansible.cfg" ]
    galaxy_file = "./requirements.yml"
  }

  post-processor "manifest" {
      output = "${local.template_dir}/manifest.json"
      strip_path = true
      custom_data = {
        timestamp = "${local.timestamp}"
      }
  }
}
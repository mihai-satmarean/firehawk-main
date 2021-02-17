# A vault client host with consul registration and signed host keys from vault.
resource "aws_security_group" "vault_client" {
  count       = var.create_vpc ? 1 : 0
  name        = var.name
  vpc_id      = var.vpc_id
  description = "Vault client security group"
  tags        = merge(map("Name", var.name), var.common_tags, local.extra_tags)
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr]
    description = "All incoming traffic from vpc"
  }
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.remote_ip_cidr_list
    security_groups = var.security_group_ids
    description = "SSH"
  }
  ingress {
    protocol    = "icmp"
    from_port   = 8
    to_port     = 0
    cidr_blocks = var.remote_ip_cidr_list
    description = "ICMP ping traffic"
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "all outgoing traffic"
  }
}
resource "vault_token" "ssh_host" { # dynamically generate a token with constrained permisions for the host role.
  role_name        = "host-vault-token-creds-role"
  policies         = ["ssh_host"]
  renewable        = false
  explicit_max_ttl = "120s"
}
data "template_file" "user_data_auth_client" {
  template = file("${path.module}/user-data-auth-ssh-host-vault-token.sh")
  vars = {
    consul_cluster_tag_key   = var.consul_cluster_tag_key
    consul_cluster_tag_value = var.consul_cluster_name
    vault_token              = vault_token.ssh_host.client_token
    aws_internal_domain      = var.aws_internal_domain
  }
}
resource "aws_instance" "vault_client" {
  count         = var.create_vpc ? 1 : 0
  ami           = var.vault_client_ami_id
  instance_type = var.instance_type
  # key_name      = var.aws_key_name # The PEM key is disabled for use in production, can be used for debugging.  Instead, signed SSH certificates should be used to access the host.
  subnet_id              = tolist(var.private_subnet_ids)[0]
  tags                   = merge(map("Name", var.name), var.common_tags, local.extra_tags)
  user_data              = data.template_file.user_data_auth_client.rendered
  iam_instance_profile   = aws_iam_instance_profile.vault_client_instance_profile.name
  vpc_security_group_ids = local.vpc_security_group_ids
  root_block_device {
    delete_on_termination = true
  }
}
resource "aws_iam_instance_profile" "vault_client_instance_profile" {
  path = "/"
  role = aws_iam_role.vault_client_instance_role.name
}
resource "aws_iam_role" "vault_client_instance_role" {
  name_prefix        = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.vault_client_instance_role.json
}
data "aws_iam_policy_document" "vault_client_instance_role" { # The policy that grants an entity permission to assume this role.
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
module "consul_iam_policies_for_client" { # Adds policies necessary for running consul
  source      = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.7.7"
  iam_role_id = aws_iam_role.vault_client_instance_role.id
}
locals {
  extra_tags = {
    role  = "vault_client"
    route = "private"
  }
  private_ip                     = element(concat(aws_instance.vault_client.*.private_ip, list("")), 0)
  id                             = element(concat(aws_instance.vault_client.*.id, list("")), 0)
  vault_client_security_group_id = element(concat(aws_security_group.vault_client.*.id, list("")), 0)
  vpc_security_group_ids         = [local.vault_client_security_group_id]
}
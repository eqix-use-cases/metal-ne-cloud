resource "random_string" "this" {
  length  = 6
  special = false
}

data "equinix_network_account" "this" {
  metro_code = var.dc_code
  name       = var.account_name
  project_id = var.fabric_project_id
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

// save this to the local disck
resource "local_sensitive_file" "private_key_pem" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${random_pet.this.id}.pem"
  file_permission = "0600"
}

resource "equinix_network_ssh_key" "this" {
  name       = random_pet.this.id
  public_key = trimspace(tls_private_key.key.public_key_openssh)
}

resource "equinix_network_acl_template" "this" {
  name        = "${random_pet.this.id}_allow_all_acl"
  description = "Allow all traffic"
  inbound_rule {
    subnet      = "0.0.0.0/0"
    protocol    = "IP"
    src_port    = "any"
    dst_port    = "any"
    description = "Allow all traffic"
  }
}

resource "equinix_network_device" "this" {
  name            = lower("${random_pet.this.id}-${data.equinix_network_account.this.metro_code}-1")
  acl_template_id = equinix_network_acl_template.this.uuid
  self_managed    = true
  byol            = true
  metro_code      = data.equinix_network_account.this.metro_code
  type_code       = var.route_os
  package_code    = var.package_code
  notifications   = var.notification_email
  hostname        = lower("${random_pet.this.id}-${data.equinix_network_account.this.metro_code}-1")
  term_length     = var.term_length
  account_number  = data.equinix_network_account.this.number
  version         = var.route_os_version
  core_count      = var.core_count
  secondary_device {
    name            = lower("${random_pet.this.id}-${data.equinix_network_account.this.metro_code}-2")
    metro_code      = data.equinix_network_account.this.metro_code
    hostname        = lower("${random_pet.this.id}-${data.equinix_network_account.this.metro_code}-2")
    notifications   = var.notification_email
    account_number  = data.equinix_network_account.this.number
    acl_template_id = equinix_network_acl_template.this.uuid
  }
  ssh_key {
    username = equinix_network_ssh_key.this.name
    key_name = equinix_network_ssh_key.this.name
  }
  timeouts {
    create = "60m"
    delete = "2h"
  }
}


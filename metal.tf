// the name
resource "random_pet" "this" {
  length = 2
}

// Metal SSH key
module "key" {
  source     = "git::github.com/andrewpopa/terraform-metal-project-ssh-key"
  project_id = var.project_id
}

// metal devices
resource "equinix_metal_device" "this" {
  for_each = var.metal

  hostname            = "${each.value.hostname}-${each.value.metro}-${random_pet.this.id}"
  plan                = each.value.plan
  metro               = each.value.metro
  operating_system    = each.value.operating_system
  billing_cycle       = each.value.billing_cycle
  project_id          = var.project_id
  project_ssh_key_ids = [module.key.id]
  user_data = templatefile("${path.module}/bootstrap/vlans.sh", {
    VLAN    = each.value.vxlan
    IP      = each.value.ip
    NETMASK = each.value.netmask
  })
}

// vlan for metal
resource "equinix_metal_vlan" "this_a" {
  metro      = var.metro_code
  vxlan      = var.vxlan_a
  project_id = var.project_id
}

resource "equinix_metal_vlan" "this_b" {
  metro      = var.metro_code
  vxlan      = var.vxlan_b
  project_id = var.project_id
}

resource "equinix_metal_vlan" "this_c" {
  metro      = var.metro_code
  vxlan      = var.vxlan_c
  project_id = var.project_id
}

// network type on each device
resource "equinix_metal_device_network_type" "this" {
  for_each  = var.metal
  device_id = equinix_metal_device.this["${each.key}"].id
  type      = each.value.network_type // layer3 interface
}

// attach device
resource "equinix_metal_port_vlan_attachment" "this" {
  for_each  = var.metal
  device_id = equinix_metal_device_network_type.this["${each.key}"].id
  port_name = each.value.port_name
  vlan_vnid = each.value.vxlan
}

// attach vlans
resource "equinix_metal_port_vlan_attachment" "a" {
  device_id = equinix_metal_device.this["dallas-1"].id
  port_name = "bond0"
  vlan_vnid = var.vxlan_c
}

resource "equinix_metal_port_vlan_attachment" "b" {
  device_id = equinix_metal_device.this["dallas-1"].id
  port_name = "bond0"
  vlan_vnid = var.vxlan_c
}

// metal connection
resource "equinix_metal_connection" "this" {
  description        = "Metal to NE"
  name               = random_pet.this.id
  project_id         = var.project_id
  type               = "shared"
  redundancy         = "redundant"
  metro              = var.metro_code
  speed              = "10Gbps"
  service_token_type = "z_side"
  vlans = [
    equinix_metal_vlan.this_a.vxlan,
    equinix_metal_vlan.this_b.vxlan
  ]
}

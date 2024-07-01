// metal

variable "project_id" {
  description = "Metal project ID"
  type        = string
  default     = ""
}

variable "metal" {
  type = map(object({
    hostname         = string
    plan             = string
    metro            = string
    operating_system = string
    billing_cycle    = string
    vxlan            = number
    network_type     = string
    port_name        = string
    ip               = string
    netmask          = string
  }))
}

variable "metro_code" {
  type    = string
  default = ""
}

variable "vxlan_a" {
  type    = number
  default = 0
}

variable "vxlan_b" {
  type    = number
  default = 0
}

variable "vxlan_c" {
  type    = number
  default = 0
}

// network edge

variable "dc_code" {
  description = "DC code for NE"
  type        = string
  default     = ""
}

variable "account_name" {
  description = "Account name for NE"
  type        = string
  default     = ""
}

variable "fabric_project_id" {
  description = "Fabric Project ID"
  type        = string
  default     = ""
}

variable "route_os" {
  type    = string
  default = ""
}

variable "package_code" {
  type    = string
  default = ""
}

variable "notification_email" {
  type    = list(any)
  default = []
}

variable "term_length" {
  type    = number
  default = 0
}

variable "route_os_version" {
  type    = string
  default = ""
}

variable "core_count" {
  type    = number
  default = 0
}

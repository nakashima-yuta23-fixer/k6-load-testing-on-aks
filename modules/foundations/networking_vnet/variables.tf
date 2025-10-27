# ==============================================================================
# INPUTS (The Public Interface of the Module)
# ==============================================================================

# --- Naming and Tagging Inputs ---
variable "customer_code" {
  description = "A short unique code for the customer or context. This value is passed to the naming module."
  type        = string
}

variable "role" {
  description = "A short name describing the primary role of this VNet (e.g., hub, spoke, app). This value is passed to the naming module."
  type        = string
}

variable "environment" {
  description = "The full name of the environment for this VNet. This value is passed to the naming module."
  type        = string
}

# --- Core Resource Inputs ---
variable "resource_group_name" {
  description = "The name of the resource group where the VNet will be created."
  type        = string
}

variable "location" {
  description = "The Azure location where the VNet will be created."
  type        = string
}

variable "vnet_address_space" {
  description = "A list of CIDR blocks for the VNet (e.g., [\"10.0.0.0/16\"])."
  type        = list(string)
}

variable "subnets" {
  description = "A map of subnet objects to be created within the VNet. The key of the map is the short name for the subnet's role."
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string), [])
    private_endpoint_network_policies = optional(string, "Disabled")
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }), null)
  }))
  default = {}
}

variable "special_subnets" {
  description = "Configuration for special, Azure-required subnets like AzureFirewallSubnet and GatewaySubnet."
  type = object({
    azure_firewall = optional(object({
      address_prefix = string
    }), null)
    vnet_gateway = optional(object({
      address_prefix = string
    }), null)
  })
  default = {
    azure_firewall = null
    vnet_gateway   = null
  }
}

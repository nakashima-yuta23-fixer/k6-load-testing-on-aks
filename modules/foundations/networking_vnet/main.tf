# ==============================================================================
# LOGIC (The Internal Implementation)
#
# This file contains the core logic for creating the VNet and its subnets.
# It is designed to be a self-contained building block, with no dependencies
# on other infrastructure components like NSGs or Route Tables.
# ==============================================================================

# ------------------------------------------------------------------------------
# Naming
# ------------------------------------------------------------------------------

module "vnet_naming" {
  source = "../../utils/naming"

  resource_type = "virtual_network"
  customer_code = var.customer_code
  role          = var.role
  environment   = var.environment
  location      = var.location
}

module "subnet_naming" {
  for_each = var.subnets
  source   = "../../utils/naming"

  resource_type = "subnet"
  customer_code = var.customer_code
  role          = each.key # Use subnet map key as the role
  environment   = var.environment
  location      = var.location
}


# ------------------------------------------------------------------------------
# Resource Creation: Virtual Network
# ------------------------------------------------------------------------------

resource "azurerm_virtual_network" "this" {
  name                = module.vnet_naming.kebab
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space

  lifecycle {
    ignore_changes = [tags]
  }
}


# ------------------------------------------------------------------------------
# Resource Creation: Subnets
# ------------------------------------------------------------------------------

# Dynamically create standard subnets based on the input map
resource "azurerm_subnet" "standard" {
  for_each = var.subnets

  name                 = module.subnet_naming[each.key].kebab
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  service_endpoints                 = each.value.service_endpoints
  private_endpoint_network_policies = each.value.private_endpoint_network_policies

  # Dynamically add a delegation block if it is defined for the subnet.
  dynamic "delegation" {
    # This block will be created only if a non-null delegation object is provided.
    for_each = try(each.value.delegation, null) != null ? [each.value.delegation] : []

    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# Create special, Azure-required subnets if their configuration is provided
resource "azurerm_subnet" "azure_firewall" {
  count = try(var.special_subnets.azure_firewall, null) != null ? 1 : 0

  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.special_subnets.azure_firewall.address_prefix]
}

resource "azurerm_subnet" "vnet_gateway" {
  count = try(var.special_subnets.vnet_gateway, null) != null ? 1 : 0

  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.special_subnets.vnet_gateway.address_prefix]
}
